package com.opu.ariftradeinternational.data.remote

import com.google.gson.annotations.SerializedName

// Generic backend envelope: { success, message, data }
data class ApiResponse<T>(
    val success: Boolean,
    val message: String,
    val data: T,
)

data class PaginatedResponse<T>(
    val data: List<T> = emptyList(),
    @SerializedName("page") val page: Int? = null,
    @SerializedName("per_page") val perPage: Int? = null,
    val total: Int? = null,
    @SerializedName("last_page") val lastPage: Int? = null,
)

data class LoginRequest(
    val email: String,
    val password: String,
)

data class LoginData(
    val token: String,
    @SerializedName("expires_in") val expiresIn: Int,
    val user: ApiUser,
)

data class ApiUser(
    val id: Int,
    val name: String,
    val email: String,
    val role: String,
)

data class ApiCategory(
    val id: Int,
    val name: String,
)

data class ApiProductSummary(
    val id: Int,
    val name: String,
    @SerializedName("product_code") val productCode: String,
    val description: String?,
    @SerializedName("is_active") val isActive: Boolean,
    @SerializedName("category_id") val categoryId: Int?,
    @SerializedName("category_name") val categoryName: String?,
)

data class ApiVariantUnit(
    val id: Int,
    @SerializedName("unit_id") val unitId: Int,
    @SerializedName("unit_name") val unitName: String,
    val multiplier: Double,
    @SerializedName("stock_quantity") val stockQuantity: Double,
    @SerializedName("unit_price") val unitPrice: Double,
)

data class ApiProductVariant(
    val id: Int,
    val sku: String,
    val attributes: Map<String, String> = emptyMap(),
    val units: List<ApiVariantUnit> = emptyList(),
)

data class ApiProductDetail(
    val id: Int,
    val name: String,
    @SerializedName("product_code") val productCode: String,
    val description: String?,
    @SerializedName("is_active") val isActive: Boolean,
    @SerializedName("category_id") val categoryId: Int?,
    @SerializedName("category_name") val categoryName: String?,
    val variants: List<ApiProductVariant> = emptyList(),
)

data class ApiCustomer(
    val id: Int,
    val name: String,
    val type: String,
    val phone: String?,
    val email: String?,
    val address: String?,
)

data class QuotationCreateItem(
    @SerializedName("variant_unit_id") val variantUnitId: Int,
    val quantity: Double,
)

data class QuotationCreateRequest(
    @SerializedName("customer_id") val customerId: Int?,
    val note: String?,
    val items: List<QuotationCreateItem>,
)

data class QuotationCreateData(
    val id: Int,
)

data class ApiQuotationListItem(
    val id: Int,
    @SerializedName("customer_id") val customerId: Int?,
    @SerializedName("customer_name") val customerName: String?,
    val status: String,
    val note: String?,
    @SerializedName("requested_at") val requestedAt: String,
)

data class ApiQuotationItem(
    val id: Int,
    @SerializedName("variant_unit_id") val variantUnitId: Int,
    val quantity: Double,
    @SerializedName("unit_price") val unitPrice: Double,
    @SerializedName("product_name") val productName: String,
    @SerializedName("unit_name") val unitName: String,
    @SerializedName("attributes") val attributes: Map<String, String> = emptyMap(),
    @SerializedName("product_code") val productCode: String,
)

data class ApiQuotationDetail(
    val id: Int,
    @SerializedName("customer_id") val customerId: Int?,
    @SerializedName("customer_name") val customerName: String?,
    val status: String,
    val note: String?,
    @SerializedName("requested_at") val requestedAt: String,
    val items: List<ApiQuotationItem> = emptyList(),
)
