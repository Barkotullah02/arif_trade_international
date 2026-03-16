package com.opu.ariftradeinternational.viewmodel

import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.opu.ariftradeinternational.data.model.*
import com.opu.ariftradeinternational.data.remote.ApiClient
import com.opu.ariftradeinternational.data.remote.LoginRequest
import com.opu.ariftradeinternational.data.remote.QuotationCreateItem
import com.opu.ariftradeinternational.data.remote.QuotationCreateRequest
import com.opu.ariftradeinternational.data.remote.toDomain
import com.opu.ariftradeinternational.data.remote.toDomainSummary
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class AppViewModel : ViewModel() {

    private val api get() = ApiClient.service()

    // ── Auth ───────────────────────────────────────────────────────────────
    var isLoggedIn   = mutableStateOf(false)
    var currentUser  = mutableStateOf<User?>(null)
    var loginError   = mutableStateOf<String?>(null)
    var isLoading    = mutableStateOf(false)
    var globalError  = mutableStateOf<String?>(null)
    var apiBaseUrl   = mutableStateOf(ApiClient.getBaseUrl())

    // ── Quotation draft (cart) ─────────────────────────────────────────────
    val draftItems       = mutableStateListOf<QuotationDraftItem>()
    var selectedCustomer = mutableStateOf<Customer?>(null)
    var quotationNote    = mutableStateOf("")

    // ── Product UI state ───────────────────────────────────────────────────
    var selectedVariant     = mutableStateOf<ProductVariant?>(null)
    var selectedVariantUnit = mutableStateOf<VariantUnit?>(null)

    // ── API-backed stores ──────────────────────────────────────────────────
    val categories = mutableStateListOf<Category>()
    val products   = mutableStateListOf<Product>()
    val customers  = mutableStateListOf<Customer>()
    val quotations = mutableStateListOf<Quotation>()

    private val productDetailCache = mutableMapOf<Int, Product>()

    fun setBaseUrl(url: String) {
        ApiClient.setBaseUrl(url)
        apiBaseUrl.value = ApiClient.getBaseUrl()
    }

    // ── Auth operations ────────────────────────────────────────────────────
    fun login(email: String, password: String) {
        if (email.isBlank() || password.isBlank()) {
            loginError.value = "Please enter your email and password."
            return
        }

        viewModelScope.launch {
            isLoading.value = true
            loginError.value = null
            globalError.value = null

            try {
                val response = withContext(Dispatchers.IO) {
                    api.login(LoginRequest(email.trim(), password))
                }
                ApiClient.setToken(response.data.token)
                currentUser.value = response.data.user.toDomain()
                isLoggedIn.value = true
                preloadData()
            } catch (e: Exception) {
                loginError.value = e.message ?: "Login failed"
            } finally {
                isLoading.value = false
            }
        }
    }

    fun logout() {
        ApiClient.clearToken()
        isLoggedIn.value  = false
        currentUser.value = null
        categories.clear()
        products.clear()
        customers.clear()
        quotations.clear()
        productDetailCache.clear()
        clearDraft()
    }

    fun preloadData() {
        loadCategories()
        loadProducts()
        loadCustomers()
        loadQuotations()
    }

    fun loadCategories() {
        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) { api.categories() }
                categories.clear()
                categories.addAll(response.data.map { it.toDomain() })
            } catch (e: Exception) {
                globalError.value = e.message ?: "Failed to load categories"
            }
        }
    }

    fun loadProducts(search: String? = null, categoryId: Int? = null) {
        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    api.products(search = search?.takeIf { it.isNotBlank() }, categoryId = categoryId)
                }
                products.clear()
                products.addAll(response.data.data.map { it.toDomainSummary() })
            } catch (e: Exception) {
                globalError.value = e.message ?: "Failed to load products"
            }
        }
    }

    fun loadProductDetail(productId: Int) {
        if (productDetailCache.containsKey(productId)) return
        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) { api.productDetail(productId) }
                val detailed = response.data.toDomain()
                productDetailCache[productId] = detailed

                val idx = products.indexOfFirst { it.id == detailed.id }
                if (idx >= 0) products[idx] = detailed else products.add(detailed)
            } catch (e: Exception) {
                globalError.value = e.message ?: "Failed to load product details"
            }
        }
    }

    fun loadCustomers(search: String? = null) {
        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    api.customers(search = search?.takeIf { it.isNotBlank() })
                }
                customers.clear()
                customers.addAll(response.data.data.map { it.toDomain() })
            } catch (e: Exception) {
                globalError.value = e.message ?: "Failed to load customers"
            }
        }
    }

    fun loadQuotations(status: String? = null) {
        viewModelScope.launch {
            try {
                val response = withContext(Dispatchers.IO) {
                    api.quotations(status = status?.takeIf { it.isNotBlank() })
                }

                // Fetch details to get line items and totals used by current UI
                val detailedQuotes = withContext(Dispatchers.IO) {
                    response.data.data.mapNotNull { listItem ->
                        try {
                            api.quotationDetail(listItem.id).data.toDomain()
                        } catch (_: Exception) {
                            listItem.toDomain()
                        }
                    }
                }

                quotations.clear()
                quotations.addAll(detailedQuotes.sortedByDescending { it.id })
            } catch (e: Exception) {
                globalError.value = e.message ?: "Failed to load quotations"
            }
        }
    }

    // ── Draft operations ───────────────────────────────────────────────────
    fun addToDraft(item: QuotationDraftItem) {
        val idx = draftItems.indexOfFirst { it.variantUnit.id == item.variantUnit.id }
        if (idx >= 0) {
            draftItems[idx] = draftItems[idx].copy(quantity = draftItems[idx].quantity + item.quantity)
        } else {
            draftItems.add(item)
        }
        // Reset selection state after adding
        selectedVariant.value     = null
        selectedVariantUnit.value = null
    }

    fun updateDraftQty(variantUnitId: Int, qty: Int) {
        val idx = draftItems.indexOfFirst { it.variantUnit.id == variantUnitId }
        if (idx >= 0 && qty > 0) draftItems[idx] = draftItems[idx].copy(quantity = qty)
    }

    fun removeDraftItem(variantUnitId: Int) {
        draftItems.removeIf { it.variantUnit.id == variantUnitId }
    }

    val draftTotal: Double
        get() = draftItems.sumOf { it.lineTotal }

    fun submitQuotation(onResult: (Boolean, String?) -> Unit) {
        val customer = selectedCustomer.value
        if (customer == null) {
            onResult(false, "Please select customer")
            return
        }
        if (draftItems.isEmpty()) {
            onResult(false, "Please add at least one product")
            return
        }

        viewModelScope.launch {
            isLoading.value = true
            try {
                val payload = QuotationCreateRequest(
                    customerId = customer.id,
                    note = quotationNote.value.trim().ifBlank { null },
                    items = draftItems.map {
                        QuotationCreateItem(
                            variantUnitId = it.variantUnit.id,
                            quantity = it.quantity.toDouble(),
                        )
                    },
                )

                withContext(Dispatchers.IO) { api.createQuotation(payload) }
                clearDraft()
                loadQuotations()
                onResult(true, null)
            } catch (e: Exception) {
                val msg = e.message ?: "Failed to submit quotation"
                globalError.value = msg
                onResult(false, msg)
            } finally {
                isLoading.value = false
            }
        }
    }

    fun clearDraft() {
        draftItems.clear()
        selectedCustomer.value    = null
        quotationNote.value       = ""
        selectedVariant.value     = null
        selectedVariantUnit.value = null
    }

    fun getQuotationById(id: Int): Quotation? = quotations.firstOrNull { it.id == id }
    fun getProductById(id: Int): Product?     = productDetailCache[id] ?: products.firstOrNull { it.id == id }
}
