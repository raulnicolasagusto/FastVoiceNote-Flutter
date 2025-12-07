#include "whisper.cpp/include/whisper.h"
#include <vector>
#include <string>
#include <thread>
#include <mutex>
#include <cstring>
#include <cmath>

#ifdef __ANDROID__
#include <android/log.h>
#define LOG_TAG "WhisperNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#else
#define LOGI(...)
#define LOGE(...)
#endif

// Export macro for making symbols visible
#if defined(_WIN32)
    #define EXPORT __declspec(dllexport)
#else
    #define EXPORT __attribute__((visibility("default")))
#endif

// Global context to keep simple (in production, use class/safe handle)
static whisper_context* g_ctx = nullptr;
static std::mutex g_mutex;

extern "C" {

    // Initialize the model
    // Returns 0 on success, -1 on error
    EXPORT int native_init_whisper(const char* model_path) {
        std::lock_guard<std::mutex> lock(g_mutex);
        
        LOGI("Initializing whisper with model: %s", model_path);
        
        if (g_ctx != nullptr) {
            whisper_free(g_ctx);
            g_ctx = nullptr;
        }

        struct whisper_context_params cparams = whisper_context_default_params();
        // cparams.use_gpu = true; // Attempt to use GPU if available (Metal/CoreML/etc) -> handled by whisper.cpp build flags

        g_ctx = whisper_init_from_file_with_params(model_path, cparams);

        if (g_ctx == nullptr) {
            LOGE("Failed to initialize whisper context");
            return -1;
        }

        LOGI("Whisper initialized successfully");
        return 0;
    }

    // Transcribe audio buffer
    // samples: PCM 16-bit converted to float (normalized -1.0 to 1.0)
    // n_samples: number of samples
    // Returns: C-string with text (caller must NOT free, handled by static or internal) - *simplification*
    // Ideally, pass a buffer to fill or return a pointer that ownership is managed.
    // For this demo, we use a thread_local string to return.
    EXPORT const char* native_transcribe(const float* samples, int n_samples) {
        std::lock_guard<std::mutex> lock(g_mutex);

        if (g_ctx == nullptr) {
            LOGE("Context not initialized");
            return "ERROR: NOT_INIT";
        }

        LOGI("Starting transcription of %d samples", n_samples);

        whisper_full_params wparams = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
        
        // Optimizations for speed on mobile
        wparams.print_progress = false;
        wparams.print_special = false;
        wparams.print_realtime = false;
        wparams.print_timestamps = false;
        
        // Basic config
        wparams.language = "es"; // Force Spanish per user app context or auto
        wparams.translate = false;
        wparams.no_timestamps = true;

        if (whisper_full(g_ctx, wparams, samples, n_samples) != 0) {
            LOGE("Whisper full failed");
            return "ERROR: TRANSCRIBE_FAILED";
        }

        int n_segments = whisper_full_n_segments(g_ctx);
        static std::string output; 
        output.clear();

        for (int i = 0; i < n_segments; ++i) {
            const char* text = whisper_full_get_segment_text(g_ctx, i);
            output += text;
        }

        LOGI("Transcription finished: %s", output.c_str());
        return output.c_str(); // Warning: Not thread safe if multiple calls happen in parallel, but here we mutex.
    }

    EXPORT void native_free_whisper() {
        std::lock_guard<std::mutex> lock(g_mutex);
        if (g_ctx != nullptr) {
            whisper_free(g_ctx);
            g_ctx = nullptr;
        }
        LOGI("Whisper freed");
    }
}
