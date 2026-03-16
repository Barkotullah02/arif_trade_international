package com.opu.ariftradeinternational.data.remote

import com.opu.ariftradeinternational.data.model.Category
import com.opu.ariftradeinternational.data.model.Customer
import com.opu.ariftradeinternational.data.model.Product
import com.opu.ariftradeinternational.data.model.ProductVariant
import com.opu.ariftradeinternational.data.model.Quotation
import com.opu.ariftradeinternational.data.model.QuotationItem
import com.opu.ariftradeinternational.data.model.QuotationStatus
import com.opu.ariftradeinternational.data.model.User
import com.opu.ariftradeinternational.data.model.VariantUnit

fun ApiUser.toDomain(): User = User(
    id = id,
    name = name,
    email = email,
    role = role,
)

fun ApiCategory.toDomain(): Category = Category(
    id = id,
    name = name,
)

fun ApiCustomer.toDomain(): Customer = Customer(
    id = id,
    name = name,
    type = type,
    phone = phone.orEmpty(),
    email = email,
    address = address,
)

fun ApiProductSummary.toDomainSummary(): Product = Product(
    id = id,
    name = name,
    productCode = productCode,
    categoryId = categoryId ?: 0,
    categoryName = categoryName ?: "Uncategorized",
    description = description.orEmpty(),
    isActive = isActive,
    variants = emptyList(),
)

fun ApiProductDetail.toDomain(): Product = Product(
    id = id,
    name = name,
    productCode = productCode,
    categoryId = categoryId ?: 0,
    categoryName = categoryName ?: "Uncategorized",
    description = description.orEmpty(),
    isActive = isActive,
    variants = variants.map { it.toDomain(id) },
)

fun ApiProductVariant.toDomain(productId: Int): ProductVariant = ProductVariant(
    id = id,
    productId = productId,
    sku = sku,
    attributes = attributes,
    units = units.map { it.toDomain(id) },
)

fun ApiVariantUnit.toDomain(variantId: Int): VariantUnit = VariantUnit(
    id = id,
    variantId = variantId,
    unitId = unitId,
    unitName = unitName,
    multiplier = multiplier,
    stockQuantity = stockQuantity.toInt(),
    unitPrice = unitPrice,
)

fun ApiQuotationListItem.toDomain(): Quotation = Quotation(
    id = id,
    customerId = customerId ?: 0,
    customerName = customerName ?: "Unknown Customer",
    customerType = "customer",
    items = emptyList(),
    status = status.toQuotationStatus(),
    note = note.orEmpty(),
    createdAt = requestedAt,
)

fun ApiQuotationDetail.toDomain(): Quotation = Quotation(
    id = id,
    customerId = customerId ?: 0,
    customerName = customerName ?: "Unknown Customer",
    customerType = "customer",
    items = items.map { it.toDomain() },
    status = status.toQuotationStatus(),
    note = note.orEmpty(),
    createdAt = requestedAt,
)

fun ApiQuotationItem.toDomain(): QuotationItem = QuotationItem(
    variantUnitId = variantUnitId,
    productName = productName,
    variantSku = productCode,
    unitName = unitName,
    quantity = quantity.toInt(),
    unitPrice = unitPrice,
)

private fun String.toQuotationStatus(): QuotationStatus = when (lowercase()) {
    "accepted" -> QuotationStatus.ACCEPTED
    "rejected" -> QuotationStatus.REJECTED
    "returned" -> QuotationStatus.RETURNED
    else -> QuotationStatus.PENDING
}
