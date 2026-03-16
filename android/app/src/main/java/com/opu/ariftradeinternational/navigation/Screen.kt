package com.opu.ariftradeinternational.navigation

sealed class Screen(val route: String) {
    object Login            : Screen("login")
    object Dashboard        : Screen("dashboard")
    object Catalog          : Screen("catalog")
    object ProductDetail    : Screen("product_detail/{productId}") {
        fun createRoute(productId: Int) = "product_detail/$productId"
    }
    object CreateQuotation  : Screen("create_quotation")
    object QuotationHistory : Screen("quotation_history")
    object QuotationDetail  : Screen("quotation_detail/{quotationId}") {
        fun createRoute(quotationId: Int) = "quotation_detail/$quotationId"
    }
}
