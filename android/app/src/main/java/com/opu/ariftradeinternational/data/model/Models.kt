package com.opu.ariftradeinternational.data.model

// ── Auth ───────────────────────────────────────────────────────────────────
data class User(
    val id: Int,
    val name: String,
    val email: String,
    val role: String,
)

// ── Product hierarchy ──────────────────────────────────────────────────────
data class Category(
    val id: Int,
    val name: String,
)

data class VariantUnit(
    val id: Int,
    val variantId: Int,
    val unitId: Int,
    val unitName: String,
    val multiplier: Double,
    val stockQuantity: Int,
    val unitPrice: Double,
)

data class ProductVariant(
    val id: Int,
    val productId: Int,
    val sku: String,
    val attributes: Map<String, String>,
    val units: List<VariantUnit>,
)

data class Product(
    val id: Int,
    val name: String,
    val productCode: String,
    val categoryId: Int,
    val categoryName: String,
    val description: String,
    val isActive: Boolean,
    val variants: List<ProductVariant>,
) {
    /** Lowest unit price across all variant-units */
    val minPrice: Double
        get() = variants.flatMap { it.units }.minOfOrNull { it.unitPrice } ?: 0.0
}

// ── Customer ───────────────────────────────────────────────────────────────
data class Customer(
    val id: Int,
    val name: String,
    val type: String,    // pharmacy | hospital | clinic | distributor
    val phone: String,
    val email: String?,
    val address: String?,
)

// ── Quotation ──────────────────────────────────────────────────────────────
enum class QuotationStatus(val label: String) {
    PENDING("Pending"),
    ACCEPTED("Accepted"),
    REJECTED("Rejected"),
    RETURNED("Returned"),
}

data class QuotationItem(
    val variantUnitId: Int,
    val productName: String,
    val variantSku: String,
    val unitName: String,
    val quantity: Int,
    val unitPrice: Double,
) {
    val total: Double get() = quantity * unitPrice
}

data class Quotation(
    val id: Int,
    val customerId: Int,
    val customerName: String,
    val customerType: String,
    val items: List<QuotationItem>,
    val status: QuotationStatus,
    val note: String,
    val createdAt: String,
) {
    val grandTotal: Double get() = items.sumOf { it.total }
    val itemCount: Int     get() = items.sumOf { it.quantity }
}

// ── Draft used while building a new quotation ──────────────────────────────
data class QuotationDraftItem(
    val variantUnit: VariantUnit,
    val productName: String,
    val variantSku: String,
    val quantity: Int,
) {
    val lineTotal: Double get() = quantity * variantUnit.unitPrice
}
