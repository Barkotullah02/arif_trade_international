package com.opu.ariftradeinternational.data.remote

import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Path
import retrofit2.http.Query

interface ApiService {
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): ApiResponse<LoginData>

    @GET("auth/me")
    suspend fun me(): ApiResponse<ApiUser>

    @GET("categories")
    suspend fun categories(): ApiResponse<List<ApiCategory>>

    @GET("products")
    suspend fun products(
        @Query("page") page: Int = 1,
        @Query("per_page") perPage: Int = 100,
        @Query("search") search: String? = null,
        @Query("category_id") categoryId: Int? = null,
        @Query("active") active: Int = 1,
    ): ApiResponse<PaginatedResponse<ApiProductSummary>>

    @GET("products/{id}")
    suspend fun productDetail(@Path("id") id: Int): ApiResponse<ApiProductDetail>

    @GET("customers")
    suspend fun customers(
        @Query("page") page: Int = 1,
        @Query("per_page") perPage: Int = 200,
        @Query("search") search: String? = null,
        @Query("type") type: String? = null,
    ): ApiResponse<PaginatedResponse<ApiCustomer>>

    @POST("quotations")
    suspend fun createQuotation(@Body request: QuotationCreateRequest): ApiResponse<QuotationCreateData>

    @GET("quotations")
    suspend fun quotations(
        @Query("page") page: Int = 1,
        @Query("per_page") perPage: Int = 100,
        @Query("status") status: String? = null,
    ): ApiResponse<PaginatedResponse<ApiQuotationListItem>>

    @GET("quotations/{id}")
    suspend fun quotationDetail(@Path("id") id: Int): ApiResponse<ApiQuotationDetail>
}
