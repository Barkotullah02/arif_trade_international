package com.opu.ariftradeinternational.data.remote

import com.google.gson.GsonBuilder
import com.opu.ariftradeinternational.BuildConfig
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object ApiClient {
    @Volatile
    private var token: String? = null

    @Volatile
    private var baseUrl: String = BuildConfig.API_BASE_URL.ensureTrailingSlash()

    @Volatile
    private var api: ApiService = buildService(baseUrl)

    fun setBaseUrl(url: String) {
        val normalized = url.ensureTrailingSlash()
        if (normalized == baseUrl) return
        baseUrl = normalized
        api = buildService(baseUrl)
    }

    fun getBaseUrl(): String = baseUrl

    fun setToken(value: String?) {
        token = value
    }

    fun clearToken() {
        token = null
    }

    fun service(): ApiService = api

    private fun buildService(url: String): ApiService {
        val authInterceptor = Interceptor { chain ->
            val original = chain.request()
            val builder = original.newBuilder()
            token?.takeIf { it.isNotBlank() }?.let { bearer ->
                builder.addHeader("Authorization", "Bearer $bearer")
            }
            chain.proceed(builder.build())
        }

        val logging = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        val client = OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(logging)
            .connectTimeout(25, TimeUnit.SECONDS)
            .readTimeout(25, TimeUnit.SECONDS)
            .writeTimeout(25, TimeUnit.SECONDS)
            .build()

        val gson = GsonBuilder().create()

        return Retrofit.Builder()
            .baseUrl(url)
            .addConverterFactory(GsonConverterFactory.create(gson))
            .client(client)
            .build()
            .create(ApiService::class.java)
    }
}

private fun String.ensureTrailingSlash(): String = if (endsWith('/')) this else "$this/"
