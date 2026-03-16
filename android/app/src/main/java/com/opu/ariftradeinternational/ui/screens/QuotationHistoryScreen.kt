package com.opu.ariftradeinternational.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForwardIos
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
import com.opu.ariftradeinternational.data.model.Quotation
import com.opu.ariftradeinternational.data.model.QuotationStatus
import com.opu.ariftradeinternational.navigation.Screen
import com.opu.ariftradeinternational.ui.components.*
import com.opu.ariftradeinternational.ui.theme.*
import com.opu.ariftradeinternational.viewmodel.AppViewModel

@Composable
fun QuotationHistoryScreen(viewModel: AppViewModel, navController: NavController) {
    val quotations      = viewModel.quotations
    var selectedFilter  by remember { mutableStateOf("All") }

    LaunchedEffect(Unit) {
        if (quotations.isEmpty()) viewModel.loadQuotations()
    }

    val filters = listOf("All", "Pending", "Accepted", "Rejected", "Returned")

    val filtered: List<Quotation> = if (selectedFilter == "All") {
        quotations.toList()
    } else {
        quotations.filter { it.status.name.equals(selectedFilter, ignoreCase = true) }
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(CreamWhite),
    ) {
        // ── Gradient header ────────────────────────────────────────────────
        Box(
            Modifier
                .fillMaxWidth()
                .background(
                    Brush.verticalGradient(listOf(GradientTop, GradientBottom))
                )
                .statusBarsPadding()
                .padding(horizontal = 20.dp, vertical = 22.dp),
        ) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Column {
                    Text("Quotation History", style = MaterialTheme.typography.headlineSmall.copy(color = White, fontWeight = FontWeight.Bold))
                    Text("${quotations.size} total requests", style = MaterialTheme.typography.bodySmall.copy(color = White.copy(alpha = 0.80f)))
                }
                Box(
                    Modifier.size(48.dp).clip(CircleShape).background(White.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(Icons.Outlined.Description, null, tint = White, modifier = Modifier.size(26.dp))
                }
            }
        }

        // ── Summary chips ──────────────────────────────────────────────────
        Row(
            Modifier
                .fillMaxWidth()
                .background(GradientBottom)
                .padding(horizontal = 20.dp, vertical = 10.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            StatusStat(label = "Pending",  count = quotations.count { it.status == QuotationStatus.PENDING  }, color = StatusPending)
            StatusStat(label = "Accepted", count = quotations.count { it.status == QuotationStatus.ACCEPTED }, color = StatusAccepted)
            StatusStat(label = "Rejected", count = quotations.count { it.status == QuotationStatus.REJECTED }, color = StatusRejected)
        }

        // ── Filter chips ───────────────────────────────────────────────────
        LazyRow(
            Modifier.fillMaxWidth().background(Surface),
            contentPadding      = PaddingValues(horizontal = 16.dp, vertical = 10.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            items(filters) { f ->
                val count = if (f == "All") quotations.size else quotations.count { it.status.name.equals(f, ignoreCase = true) }
                FilterChip(
                    selected          = selectedFilter == f,
                    onClick           = { selectedFilter = f },
                    label             = { Text("$f ($count)", style = MaterialTheme.typography.labelMedium) },
                    colors            = FilterChipDefaults.filterChipColors(
                        selectedContainerColor    = MauveGray,
                        selectedLabelColor        = White,
                        containerColor            = SurfaceVariant,
                        labelColor                = TextSecondary,
                    ),
                    border = FilterChipDefaults.filterChipBorder(
                        enabled          = true,
                        selected         = selectedFilter == f,
                        borderColor      = Divider,
                        selectedBorderColor = MauveGray,
                        borderWidth      = 1.dp,
                        selectedBorderWidth = 1.dp,
                    ),
                )
            }
        }

        HorizontalDivider(color = Divider, thickness = 1.dp)

        // ── Main list ──────────────────────────────────────────────────────
        if (filtered.isEmpty()) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                EmptyState(
                    icon     = Icons.Outlined.FindInPage,
                    title    = "No $selectedFilter quotations",
                    subtitle = if (selectedFilter == "All") "You haven't submitted any quotations yet"
                               else "No quotations with status \"$selectedFilter\"",
                )
            }
        } else {
            LazyColumn(
                contentPadding      = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(filtered.sortedByDescending { it.id }, key = { it.id }) { q ->
                    QuotationHistoryCard(
                        quotation = q,
                        onClick   = {
                            navController.navigate(Screen.QuotationDetail.createRoute(q.id))
                        },
                    )
                }
                item { Spacer(Modifier.height(16.dp)) }
            }
        }
    }
}

// ── Sub-composables ────────────────────────────────────────────────────────

@Composable
private fun RowScope.StatusStat(label: String, count: Int, color: androidx.compose.ui.graphics.Color) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(5.dp)) {
        Box(Modifier.size(8.dp).clip(CircleShape).background(color))
        Text(
            "$count $label",
            style = MaterialTheme.typography.labelSmall.copy(color = White.copy(alpha = 0.90f)),
        )
    }
}

@Composable
private fun QuotationHistoryCard(quotation: Quotation, onClick: () -> Unit) {
    val dateStr = quotation.createdAt

    Card(
        modifier  = Modifier.fillMaxWidth().clickable(onClick = onClick),
        shape     = RoundedCornerShape(14.dp),
        colors    = CardDefaults.cardColors(containerColor = Surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Column(Modifier.padding(16.dp)) {
            // Top row: quotation ID + status badge
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "QT-${quotation.id.toString().padStart(5, '0')}",
                    style = MaterialTheme.typography.labelMedium.copy(color = TextHint, fontWeight = FontWeight.Medium),
                )
                StatusBadge(quotation.status)
            }
            Spacer(Modifier.height(8.dp))

            // Customer row
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Box(
                    Modifier.size(36.dp).clip(CircleShape).background(MauveLight),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        quotation.customerName.take(1).uppercase(),
                        style = MaterialTheme.typography.labelMedium.copy(color = MauveGray, fontWeight = FontWeight.Bold),
                    )
                }
                Column {
                    Text(quotation.customerName, style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold))
                    Text(quotation.customerType, style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary))
                }
            }
            Spacer(Modifier.height(12.dp))
            HorizontalDivider(color = Divider)
            Spacer(Modifier.height(10.dp))

            // Bottom stats row
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    MiniStat(icon = Icons.Outlined.Inventory2, value = "${quotation.itemCount} items")
                    MiniStat(icon = Icons.Outlined.DateRange,   value = dateStr)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        formatPKR(quotation.grandTotal),
                        style = MaterialTheme.typography.titleSmall.copy(color = MauveGray, fontWeight = FontWeight.Bold),
                    )
                    Spacer(Modifier.width(4.dp))
                    Icon(Icons.Filled.ArrowForwardIos, null, tint = TextHint, modifier = Modifier.size(12.dp))
                }
            }
        }
    }
}

@Composable
private fun MiniStat(icon: androidx.compose.ui.graphics.vector.ImageVector, value: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        Icon(icon, null, tint = TextHint, modifier = Modifier.size(13.dp))
        Text(value, style = MaterialTheme.typography.labelSmall.copy(color = TextHint))
    }
}
