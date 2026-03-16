package com.opu.ariftradeinternational.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.opu.ariftradeinternational.navigation.Screen
import com.opu.ariftradeinternational.ui.components.*
import com.opu.ariftradeinternational.ui.theme.*
import com.opu.ariftradeinternational.viewmodel.AppViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CatalogScreen(viewModel: AppViewModel, navController: NavController) {
    var searchQuery       by remember { mutableStateOf("") }
    var selectedCategory  by remember { mutableStateOf<Int?>(null) }

    val allProducts = viewModel.products
    val categories  = viewModel.categories

    LaunchedEffect(Unit) {
        if (categories.isEmpty()) viewModel.loadCategories()
        if (allProducts.isEmpty()) viewModel.loadProducts()
    }

    val filtered = allProducts.filter { p ->
        val matchSearch   = searchQuery.isBlank() ||
            p.name.contains(searchQuery, ignoreCase = true) ||
            p.productCode.contains(searchQuery, ignoreCase = true) ||
            p.categoryName.contains(searchQuery, ignoreCase = true)
        val matchCategory = selectedCategory == null || p.categoryId == selectedCategory
        matchSearch && matchCategory && p.isActive
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(CreamWhite),
    ) {
        // ── Header ─────────────────────────────────────────────────────────
        Box(
            Modifier
                .fillMaxWidth()
                .background(Brush.verticalGradient(listOf(GradientTop, MauveGray)))
                .padding(horizontal = 16.dp)
                .padding(top = 52.dp, bottom = 16.dp),
        ) {
            Column {
                Text(
                    "Product Catalog",
                    style = MaterialTheme.typography.headlineMedium.copy(color = White, fontWeight = FontWeight.Bold),
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    "${allProducts.size} products across ${categories.size} categories",
                    style = MaterialTheme.typography.bodySmall.copy(color = White.copy(alpha = 0.78f)),
                )
                Spacer(Modifier.height(14.dp))

                // Search bar
                OutlinedTextField(
                    value         = searchQuery,
                    onValueChange = { searchQuery = it },
                    placeholder   = { Text("Search products...", style = MaterialTheme.typography.bodyMedium.copy(color = White.copy(alpha = 0.60f))) },
                    leadingIcon   = { Icon(Icons.Outlined.Search, null, tint = White.copy(alpha = 0.80f)) },
                    trailingIcon  = {
                        if (searchQuery.isNotEmpty()) {
                            IconButton(onClick = { searchQuery = "" }) {
                                Icon(Icons.Filled.Clear, null, tint = White.copy(alpha = 0.80f))
                            }
                        }
                    },
                    singleLine    = true,
                    modifier      = Modifier.fillMaxWidth(),
                    shape         = RoundedCornerShape(12.dp),
                    colors        = OutlinedTextFieldDefaults.colors(
                        focusedTextColor     = White,
                        unfocusedTextColor   = White,
                        focusedBorderColor   = White.copy(alpha = 0.60f),
                        unfocusedBorderColor = White.copy(alpha = 0.35f),
                        cursorColor          = White,
                        focusedContainerColor   = White.copy(alpha = 0.12f),
                        unfocusedContainerColor = White.copy(alpha = 0.10f),
                    ),
                )
            }
        }

        // ── Category filter chips ──────────────────────────────────────────
        Row(
            Modifier
                .horizontalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 10.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            FilterChip(
                selected = selectedCategory == null,
                onClick  = { selectedCategory = null },
                label    = { Text("All") },
                leadingIcon = if (selectedCategory == null) {
                    { Icon(Icons.Filled.Check, null, Modifier.size(16.dp)) }
                } else null,
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor       = MauveGray,
                    selectedLabelColor           = White,
                    selectedLeadingIconColor     = White,
                    containerColor               = Surface,
                    labelColor                   = TextSecondary,
                ),
            )
            categories.forEach { cat ->
                val sel = selectedCategory == cat.id
                FilterChip(
                    selected = sel,
                    onClick  = { selectedCategory = if (sel) null else cat.id },
                    label    = { Text(cat.name) },
                    leadingIcon = if (sel) {
                        { Icon(Icons.Filled.Check, null, Modifier.size(16.dp)) }
                    } else null,
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor   = MauveGray,
                        selectedLabelColor       = White,
                        selectedLeadingIconColor = White,
                        containerColor           = Surface,
                        labelColor               = TextSecondary,
                    ),
                )
            }
        }

        // ── Results count ──────────────────────────────────────────────────
        Row(
            Modifier.padding(horizontal = 16.dp).padding(bottom = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                "${filtered.size} product${if (filtered.size != 1) "s" else ""}",
                style = MaterialTheme.typography.labelMedium.copy(color = TextSecondary),
            )
        }

        // ── Product grid ───────────────────────────────────────────────────
        if (filtered.isEmpty()) {
            EmptyState(
                icon     = Icons.Outlined.SearchOff,
                title    = "No products found",
                subtitle = "Try a different search or category filter",
                modifier = Modifier.padding(top = 24.dp),
                action   = {
                    OutlinedButton(
                        onClick = { searchQuery = ""; selectedCategory = null },
                        shape   = RoundedCornerShape(10.dp),
                    ) {
                        Text("Clear Filters")
                    }
                },
            )
        } else {
            LazyVerticalGrid(
                columns            = GridCells.Fixed(2),
                contentPadding     = PaddingValues(horizontal = 12.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement   = Arrangement.spacedBy(10.dp),
                modifier           = Modifier.fillMaxSize(),
            ) {
                items(filtered) { product ->
                    val stockTotal = product.variants.flatMap { it.units }.sumOf { it.stockQuantity }
                    ProductCard(
                        name        = product.name,
                        code        = product.productCode,
                        category    = product.categoryName,
                        minPrice    = product.minPrice,
                        stockCount  = stockTotal,
                        accentColor = categoryColor(product.categoryName),
                        onClick     = {
                            navController.navigate(Screen.ProductDetail.createRoute(product.id))
                        },
                    )
                }
                // bottom padding item
                item { Spacer(Modifier.height(8.dp)) }
                item { Spacer(Modifier.height(8.dp)) }
            }
        }
    }
}
