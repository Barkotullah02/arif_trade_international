package com.opu.ariftradeinternational.navigation

import androidx.compose.animation.*
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.navigation.*
import androidx.navigation.compose.*
import com.opu.ariftradeinternational.ui.screens.*
import com.opu.ariftradeinternational.ui.theme.*
import com.opu.ariftradeinternational.viewmodel.AppViewModel

// ── Bottom nav items ───────────────────────────────────────────────────────
private data class BottomNavItem(
    val label: String,
    val route: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
)

private val bottomNavItems = listOf(
    BottomNavItem("Home",      Screen.Dashboard.route,        Icons.Filled.Home,          Icons.Outlined.Home),
    BottomNavItem("Catalog",   Screen.Catalog.route,          Icons.Filled.Inventory2,    Icons.Outlined.Inventory2),
    BottomNavItem("Quotations",Screen.QuotationHistory.route, Icons.Filled.Receipt,       Icons.Outlined.Receipt),
)

// ── Main entry point ───────────────────────────────────────────────────────
@Composable
fun AppNavigation(viewModel: AppViewModel) {
    val navController = rememberNavController()

    NavHost(
        navController    = navController,
        startDestination = Screen.Login.route,
        enterTransition  = { fadeIn(tween(220))  + slideInHorizontally(tween(220)) { it / 4 } },
        exitTransition   = { fadeOut(tween(180)) + slideOutHorizontally(tween(180)) { -it / 4 } },
        popEnterTransition  = { fadeIn(tween(220))  + slideInHorizontally(tween(220)) { -it / 4 } },
        popExitTransition   = { fadeOut(tween(180)) + slideOutHorizontally(tween(180)) { it / 4 } },
    ) {

        // ── Auth ──────────────────────────────────────────────────────────
        composable(Screen.Login.route) {
            LoginScreen(
                viewModel = viewModel,
                onLoginSuccess = {
                    navController.navigate(Screen.Dashboard.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                },
            )
        }

        // ── Main tabs (with shared bottom bar) ───────────────────────────
        composable(Screen.Dashboard.route) {
            MainScaffold(navController, Screen.Dashboard.route, viewModel) {
                DashboardScreen(viewModel = viewModel, navController = navController)
            }
        }
        composable(Screen.Catalog.route) {
            MainScaffold(navController, Screen.Catalog.route, viewModel) {
                CatalogScreen(viewModel = viewModel, navController = navController)
            }
        }
        composable(Screen.QuotationHistory.route) {
            MainScaffold(navController, Screen.QuotationHistory.route, viewModel) {
                QuotationHistoryScreen(viewModel = viewModel, navController = navController)
            }
        }

        // ── Detail screens (no bottom bar) ───────────────────────────────
        composable(
            route     = Screen.ProductDetail.route,
            arguments = listOf(navArgument("productId") { type = NavType.IntType }),
        ) { back ->
            val productId = back.arguments?.getInt("productId") ?: return@composable
            ProductDetailScreen(
                productId     = productId,
                viewModel     = viewModel,
                navController = navController,
            )
        }

        composable(Screen.CreateQuotation.route) {
            CreateQuotationScreen(viewModel = viewModel, navController = navController)
        }

        composable(
            route     = Screen.QuotationDetail.route,
            arguments = listOf(navArgument("quotationId") { type = NavType.IntType }),
        ) { back ->
            val quotationId = back.arguments?.getInt("quotationId") ?: return@composable
            QuotationDetailScreen(
                quotationId   = quotationId,
                viewModel     = viewModel,
                navController = navController,
            )
        }
    }
}

// ── Shared scaffold with bottom navigation ─────────────────────────────────
@Composable
private fun MainScaffold(
    navController: NavHostController,
    currentRoute: String,
    viewModel: AppViewModel,
    content: @Composable () -> Unit,
) {
    val draftCount = viewModel.draftItems.size

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.surface,
                tonalElevation = 4.dp,
            ) {
                bottomNavItems.forEach { item ->
                    val selected = currentRoute == item.route
                    NavigationBarItem(
                        selected = selected,
                        onClick  = {
                            if (!selected) {
                                navController.navigate(item.route) {
                                    popUpTo(Screen.Dashboard.route) { saveState = true }
                                    launchSingleTop = true
                                    restoreState    = true
                                }
                            }
                        },
                        icon  = {
                            BadgedBox(
                                badge = {
                                    if (item.route == Screen.QuotationHistory.route && draftCount > 0) {
                                        Badge { Text("$draftCount") }
                                    }
                                },
                            ) {
                                Icon(
                                    imageVector  = if (selected) item.selectedIcon else item.unselectedIcon,
                                    contentDescription = item.label,
                                )
                            }
                        },
                        label = { Text(item.label) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor   = MauveGray,
                            selectedTextColor   = MauveGray,
                            indicatorColor      = MauveLight,
                            unselectedIconColor = TextHint,
                            unselectedTextColor = TextHint,
                        ),
                    )
                }
            }
        },
    ) { innerPadding ->
        androidx.compose.foundation.layout.Box(Modifier.padding(innerPadding)) {
            content()
        }
    }
}
