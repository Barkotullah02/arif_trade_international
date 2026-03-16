package com.opu.ariftradeinternational.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
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
import com.opu.ariftradeinternational.data.model.*
import com.opu.ariftradeinternational.navigation.Screen
import com.opu.ariftradeinternational.ui.components.*
import com.opu.ariftradeinternational.ui.theme.*
import com.opu.ariftradeinternational.viewmodel.AppViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProductDetailScreen(
    productId: Int,
    viewModel: AppViewModel,
    navController: NavController,
) {
    LaunchedEffect(productId) {
        viewModel.loadProductDetail(productId)
    }

    val product = viewModel.getProductById(productId)

    if (product == null) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator(color = MauveGray)
        }
        return
    }

    var selectedVariant by remember { mutableStateOf(product.variants.firstOrNull()) }
    var selectedUnit    by remember { mutableStateOf(product.variants.firstOrNull()?.units?.firstOrNull()) }
    var quantity        by remember { mutableIntStateOf(1) }

    val accentColor = categoryColor(product.categoryName)
    var addedSnack by remember { mutableStateOf(false) }

    LaunchedEffect(addedSnack) {
        if (addedSnack) {
            kotlinx.coroutines.delay(2000)
            addedSnack = false
        }
    }

    Scaffold(
        topBar = {
            DetailTopBar(
                title  = product.name,
                onBack = { navController.popBackStack() },
                actions = {
                    IconButton(onClick = { navController.navigate(Screen.CreateQuotation.route) }) {
                        BadgedBox(
                            badge = {
                                if (viewModel.draftItems.isNotEmpty())
                                    Badge { Text("${viewModel.draftItems.size}") }
                            },
                        ) {
                            Icon(Icons.Outlined.ShoppingCart, "Cart", tint = White)
                        }
                    }
                },
            )
        },
        bottomBar = {
            // Add to quotation bottom button
            Surface(
                shadowElevation = 8.dp,
                color           = Surface,
            ) {
                Row(
                    Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                        .navigationBarsPadding(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment     = Alignment.CenterVertically,
                ) {
                    // Qty stepper
                    QuantityStepper(
                        value       = quantity,
                        onDecrement = { if (quantity > 1) quantity-- },
                        onIncrement = { quantity++ },
                    )
                    // Add button
                    Button(
                        onClick = {
                            selectedUnit?.let { unit ->
                                viewModel.addToDraft(
                                    QuotationDraftItem(
                                        variantUnit  = unit,
                                        productName  = product.name,
                                        variantSku   = selectedVariant?.sku ?: "",
                                        quantity     = quantity,
                                    ),
                                )
                                quantity   = 1
                                addedSnack = true
                            }
                        },
                        enabled  = selectedUnit != null,
                        modifier = Modifier.weight(1f).height(50.dp),
                        shape    = RoundedCornerShape(12.dp),
                        colors   = ButtonDefaults.buttonColors(containerColor = MauveGray),
                    ) {
                        Icon(Icons.Filled.Add, null, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(6.dp))
                        Text("Add to Quotation", style = MaterialTheme.typography.labelLarge.copy(color = White))
                    }
                }
            }
        },
        snackbarHost = {
            if (addedSnack) {
                Snackbar(
                    modifier = Modifier.padding(16.dp),
                    shape    = RoundedCornerShape(12.dp),
                    containerColor = StatusAcceptedBg,
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.CheckCircle, null, tint = StatusAccepted, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Added to quotation draft", style = MaterialTheme.typography.bodyMedium.copy(color = StatusAccepted))
                    }
                }
            }
        },
    ) { innerPadding ->
        Column(
            Modifier
                .fillMaxSize()
                .background(CreamWhite)
                .verticalScroll(rememberScrollState())
                .padding(innerPadding),
        ) {
            // ── Product hero ───────────────────────────────────────────────
            Box(
                Modifier
                    .fillMaxWidth()
                    .height(160.dp)
                    .background(Brush.verticalGradient(listOf(accentColor, accentColor.copy(alpha = 0.70f)))),
                contentAlignment = Alignment.Center,
            ) {
                // Decorative icon
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                        Modifier
                            .size(72.dp)
                            .clip(CircleShape)
                            .background(White.copy(alpha = 0.18f))
                            .border(2.dp, White.copy(alpha = 0.30f), CircleShape),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(Icons.Outlined.Inventory2, null, tint = White, modifier = Modifier.size(36.dp))
                    }
                    Spacer(Modifier.height(8.dp))
                    Surface(
                        shape = RoundedCornerShape(20.dp),
                        color = White.copy(alpha = 0.20f),
                    ) {
                        Text(
                            product.productCode,
                            style    = MaterialTheme.typography.labelMedium.copy(color = White),
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                        )
                    }
                }
            }

            // ── Product details card ───────────────────────────────────────
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {

                Card(
                    shape  = RoundedCornerShape(14.dp),
                    colors = CardDefaults.cardColors(containerColor = Surface),
                    elevation = CardDefaults.cardElevation(2.dp),
                ) {
                    Column(Modifier.padding(16.dp)) {
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment     = Alignment.Top,
                        ) {
                            Column(Modifier.weight(1f)) {
                                Text(
                                    product.name,
                                    style = MaterialTheme.typography.headlineSmall.copy(
                                        color = TextPrimary, fontWeight = FontWeight.Bold,
                                    ),
                                )
                                Spacer(Modifier.height(4.dp))
                                Surface(
                                    shape = RoundedCornerShape(6.dp),
                                    color = accentColor.copy(alpha = 0.12f),
                                ) {
                                    Text(
                                        product.categoryName,
                                        style    = MaterialTheme.typography.labelSmall.copy(color = accentColor, fontWeight = FontWeight.SemiBold),
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
                                    )
                                }
                            }
                        }

                        if (product.description.isNotBlank()) {
                            Spacer(Modifier.height(12.dp))
                            HorizontalDivider(color = Divider)
                            Spacer(Modifier.height(12.dp))
                            Text(
                                product.description,
                                style = MaterialTheme.typography.bodyMedium.copy(color = TextSecondary, lineHeight = MaterialTheme.typography.bodyMedium.lineHeight),
                            )
                        }
                    }
                }

                // ── Variant selector ───────────────────────────────────────
                if (product.variants.size > 1) {
                    Card(
                        shape  = RoundedCornerShape(14.dp),
                        colors = CardDefaults.cardColors(containerColor = Surface),
                        elevation = CardDefaults.cardElevation(2.dp),
                    ) {
                        Column(Modifier.padding(16.dp)) {
                            SectionHeader("Select Variant")
                            Spacer(Modifier.height(10.dp))
                            product.variants.forEach { variant ->
                                val isSelected = selectedVariant?.id == variant.id
                                val attrText = variant.attributes.entries.joinToString(" · ") { "${it.key}: ${it.value}" }
                                Surface(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(bottom = 8.dp)
                                        .clickable {
                                            selectedVariant = variant
                                            selectedUnit    = variant.units.firstOrNull()
                                        },
                                    shape     = RoundedCornerShape(10.dp),
                                    color     = if (isSelected) MauveLight else SurfaceVariant,
                                    border    = if (isSelected) BorderStroke(1.5.dp, MauveGray) else null,
                                ) {
                                    Row(
                                        Modifier.padding(12.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                    ) {
                                        Box(
                                            Modifier
                                                .size(20.dp)
                                                .clip(CircleShape)
                                                .background(if (isSelected) MauveGray else Divider),
                                            contentAlignment = Alignment.Center,
                                        ) {
                                            if (isSelected) Icon(Icons.Filled.Check, null, tint = White, modifier = Modifier.size(12.dp))
                                        }
                                        Spacer(Modifier.width(10.dp))
                                        Column {
                                            Text(variant.sku, style = MaterialTheme.typography.titleSmall.copy(color = if (isSelected) MauveDeep else TextPrimary, fontWeight = FontWeight.SemiBold))
                                            Text(attrText,    style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Unit / pack size selector ──────────────────────────────
                selectedVariant?.let { variant ->
                    Card(
                        shape  = RoundedCornerShape(14.dp),
                        colors = CardDefaults.cardColors(containerColor = Surface),
                        elevation = CardDefaults.cardElevation(2.dp),
                    ) {
                        Column(Modifier.padding(16.dp)) {
                            SectionHeader("Select Unit / Pack Size")
                            Spacer(Modifier.height(10.dp))
                            variant.units.forEach { unit ->
                                val isSelected = selectedUnit?.id == unit.id
                                Surface(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(bottom = 8.dp)
                                        .clickable { selectedUnit = unit },
                                    shape  = RoundedCornerShape(10.dp),
                                    color  = if (isSelected) MauveLight else SurfaceVariant,
                                    border = if (isSelected) BorderStroke(1.5.dp, MauveGray) else null,
                                ) {
                                    Row(
                                        Modifier.padding(12.dp),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment     = Alignment.CenterVertically,
                                    ) {
                                        Row(verticalAlignment = Alignment.CenterVertically) {
                                            Box(
                                                Modifier.size(20.dp).clip(CircleShape).background(if (isSelected) MauveGray else Divider),
                                                contentAlignment = Alignment.Center,
                                            ) {
                                                if (isSelected) Icon(Icons.Filled.Check, null, tint = White, modifier = Modifier.size(12.dp))
                                            }
                                            Spacer(Modifier.width(10.dp))
                                            Column {
                                                Text(unit.unitName, style = MaterialTheme.typography.titleSmall.copy(color = if (isSelected) MauveDeep else TextPrimary, fontWeight = FontWeight.SemiBold))
                                                Row(verticalAlignment = Alignment.CenterVertically) {
                                                    Icon(Icons.Outlined.Inventory, null, tint = TextHint, modifier = Modifier.size(12.dp))
                                                    Spacer(Modifier.width(3.dp))
                                                    Text("${unit.stockQuantity} in stock", style = MaterialTheme.typography.labelSmall.copy(color = if (unit.stockQuantity > 10) StatusAccepted else StatusPending))
                                                }
                                            }
                                        }
                                        Text(
                                            formatPKR(unit.unitPrice),
                                            style = MaterialTheme.typography.titleSmall.copy(
                                                color = if (isSelected) MauveGray else TextPrimary,
                                                fontWeight = FontWeight.Bold,
                                            ),
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Price summary strip ────────────────────────────────────
                selectedUnit?.let { unit ->
                    Card(
                        shape  = RoundedCornerShape(14.dp),
                        colors = CardDefaults.cardColors(containerColor = MauveLight),
                        elevation = CardDefaults.cardElevation(0.dp),
                    ) {
                        Row(
                            Modifier.fillMaxWidth().padding(16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment     = Alignment.CenterVertically,
                        ) {
                            Column {
                                Text("Unit Price", style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary))
                                Text(formatPKR(unit.unitPrice), style = MaterialTheme.typography.titleLarge.copy(color = MauveDeep, fontWeight = FontWeight.Bold))
                            }
                            Column(horizontalAlignment = Alignment.End) {
                                Text("Line Total (qty $quantity)", style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary))
                                Text(formatPKR(unit.unitPrice * quantity), style = MaterialTheme.typography.titleLarge.copy(color = MauveGray, fontWeight = FontWeight.Bold))
                            }
                        }
                    }
                }

                Spacer(Modifier.height(4.dp))
            }
        }
    }
}
