package com.opu.ariftradeinternational.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.opu.ariftradeinternational.data.model.Quotation
import com.opu.ariftradeinternational.data.model.QuotationItem
import com.opu.ariftradeinternational.ui.components.*
import com.opu.ariftradeinternational.ui.theme.*
import com.opu.ariftradeinternational.viewmodel.AppViewModel


@Composable
fun QuotationDetailScreen(quotationId: Int, viewModel: AppViewModel, navController: NavController) {
    LaunchedEffect(Unit) {
        if (viewModel.quotations.none { it.id == quotationId }) {
            viewModel.loadQuotations()
        }
    }

    val quotation = viewModel.getQuotationById(quotationId)

    if (quotation == null) {
        // Rarely happens; guard anyway
        Box(Modifier.fillMaxSize().background(CreamWhite), contentAlignment = Alignment.Center) {
            EmptyState(
                icon     = Icons.Outlined.ErrorOutline,
                title    = "Quotation not found",
                subtitle = "ID: $quotationId",
            )
        }
        return
    }

    Scaffold(
        topBar = {
            DetailTopBar(
                title  = "QT-${quotation.id.toString().padStart(5, '0')}",
                onBack = { navController.popBackStack() },
            )
        },
        containerColor = CreamWhite,
    ) { innerPadding ->
        LazyColumn(
            Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding      = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            // ── Status banner ──────────────────────────────────────────────
            item { StatusBanner(quotation) }

            // ── Customer info card ─────────────────────────────────────────
            item { CustomerInfoCard(quotation) }

            // ── Items card ─────────────────────────────────────────────────
            item {
                Card(
                    shape     = RoundedCornerShape(14.dp),
                    colors    = CardDefaults.cardColors(containerColor = Surface),
                    elevation = CardDefaults.cardElevation(2.dp),
                ) {
                    Column(Modifier.padding(16.dp)) {
                        SectionHeader(
                            title  = "Ordered Items",
                            action = {
                                Text(
                                    "${quotation.itemCount} item(s)",
                                    style = MaterialTheme.typography.labelSmall.copy(color = TextHint),
                                )
                            },
                        )
                        Spacer(Modifier.height(12.dp))

                        quotation.items.forEachIndexed { idx, item ->
                            QuotationItemRow(item, idx + 1)
                            if (idx < quotation.items.lastIndex) {
                                HorizontalDivider(color = Divider, modifier = Modifier.padding(vertical = 8.dp))
                            }
                        }

                        HorizontalDivider(color = Divider, modifier = Modifier.padding(top = 12.dp, bottom = 10.dp))

                        // Grand total row
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                            Text("Grand Total", style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.Bold))
                            Text(
                                formatPKR(quotation.grandTotal),
                                style = MaterialTheme.typography.titleMedium.copy(color = MauveGray, fontWeight = FontWeight.ExtraBold),
                            )
                        }
                    }
                }
            }

            // ── Note card (if present) ─────────────────────────────────────
            if (quotation.note.isNotBlank()) {
                item { NoteCard(note = quotation.note) }
            }

            // ── Timeline card ─────────────────────────────────────────────
            item { TimelineCard(quotation) }

            item { Spacer(Modifier.height(20.dp)) }
        }
    }
}

// ── Sub-composables ────────────────────────────────────────────────────────

@Composable
private fun StatusBanner(quotation: Quotation) {
    Surface(
        shape  = RoundedCornerShape(14.dp),
        color  = when (quotation.status.name) {
            "ACCEPTED" -> StatusAcceptedBg
            "REJECTED" -> StatusRejectedBg
            "RETURNED" -> StatusReturnedBg
            else       -> StatusPendingBg
        },
        border = androidx.compose.foundation.BorderStroke(
            1.dp,
            when (quotation.status.name) {
                "ACCEPTED" -> StatusAccepted.copy(alpha = 0.40f)
                "REJECTED" -> StatusRejected.copy(alpha = 0.40f)
                "RETURNED" -> StatusReturned.copy(alpha = 0.40f)
                else       -> StatusPending.copy(alpha = 0.40f)
            }
        ),
    ) {
        Row(
            Modifier.fillMaxWidth().padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Column {
                Text("Status", style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary))
                Spacer(Modifier.height(4.dp))
                StatusBadge(quotation.status)
            }
            Column(horizontalAlignment = Alignment.End) {
                Text("Submitted on", style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary))
                Spacer(Modifier.height(4.dp))
                Text(
                    quotation.createdAt,
                    style = MaterialTheme.typography.labelMedium.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold),
                )
            }
        }
    }
}

@Composable
private fun CustomerInfoCard(quotation: Quotation) {
    Card(
        shape     = RoundedCornerShape(14.dp),
        colors    = CardDefaults.cardColors(containerColor = Surface),
        elevation = CardDefaults.cardElevation(2.dp),
    ) {
        Column(Modifier.padding(16.dp)) {
            SectionHeader(title = "Customer / Doctor")
            Spacer(Modifier.height(12.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    Modifier.size(52.dp).clip(CircleShape).background(MauveGray),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        quotation.customerName.take(1).uppercase(),
                        style = MaterialTheme.typography.titleLarge.copy(color = White, fontWeight = FontWeight.Bold),
                    )
                }
                Spacer(Modifier.width(14.dp))
                Column {
                    Text(quotation.customerName, style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.Bold))
                    Spacer(Modifier.height(4.dp))
                    CustomerTypeBadge(quotation.customerType)
                }
            }
        }
    }
}

@Composable
private fun QuotationItemRow(item: QuotationItem, index: Int) {
    Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.Top) {
        // Index circle
        Box(
            Modifier.size(24.dp).clip(CircleShape).background(SurfaceVariant),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                "$index",
                style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary, fontWeight = FontWeight.Bold),
            )
        }
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f)) {
            Text(item.productName, style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold))
            Text(
                "${item.variantSku}  ·  ${item.unitName}",
                style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary),
            )
        }
        Spacer(Modifier.width(8.dp))
        Column(horizontalAlignment = Alignment.End) {
            Text(
                "${item.quantity} × ${formatPKR(item.unitPrice)}",
                style = MaterialTheme.typography.labelSmall.copy(color = TextHint),
            )
            Text(
                formatPKR(item.total),
                style = MaterialTheme.typography.labelMedium.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold),
            )
        }
    }
}

@Composable
private fun NoteCard(note: String) {
    Card(
        shape     = RoundedCornerShape(14.dp),
        colors    = CardDefaults.cardColors(containerColor = Surface),
        elevation = CardDefaults.cardElevation(2.dp),
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Icon(Icons.Outlined.StickyNote2, null, tint = DustyRose, modifier = Modifier.size(18.dp))
                Text("Note", style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.Bold))
            }
            Spacer(Modifier.height(8.dp))
            Text(
                note,
                style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary),
            )
        }
    }
}

@Composable
private fun TimelineCard(quotation: Quotation) {
    Card(
        shape     = RoundedCornerShape(14.dp),
        colors    = CardDefaults.cardColors(containerColor = Surface),
        elevation = CardDefaults.cardElevation(2.dp),
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Icon(Icons.Outlined.Timeline, null, tint = MauveGray, modifier = Modifier.size(18.dp))
                Text("Timeline", style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.Bold))
            }
            Spacer(Modifier.height(12.dp))

            val dateStr = quotation.createdAt

            TimelineRow(
                icon    = Icons.Outlined.Send,
                label   = "Submitted",
                detail  = dateStr,
                isFirst = true,
                isDone  = true,
            )
            TimelineRow(
                icon   = Icons.Outlined.Pending,
                label  = "Under Review",
                detail = "Awaiting confirmation",
                isDone = quotation.status.name != "PENDING",
            )
            TimelineRow(
                icon    = when (quotation.status.name) {
                    "ACCEPTED" -> Icons.Outlined.CheckCircle
                    "REJECTED" -> Icons.Outlined.Cancel
                    "RETURNED" -> Icons.Outlined.Undo
                    else       -> Icons.Outlined.HourglassEmpty
                },
                label  = when (quotation.status.name) {
                    "ACCEPTED" -> "Accepted"
                    "REJECTED" -> "Rejected"
                    "RETURNED" -> "Returned"
                    else       -> "Final Decision"
                },
                detail  = if (quotation.status.name == "PENDING") "Pending" else "Completed",
                isLast  = true,
                isDone  = quotation.status.name != "PENDING",
            )
        }
    }
}

@Composable
private fun TimelineRow(
    icon: ImageVector,
    label: String,
    detail: String,
    isFirst: Boolean = false,
    isLast: Boolean  = false,
    isDone: Boolean  = false,
) {
    Row(Modifier.fillMaxWidth()) {
        // Connector column
        Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.width(32.dp)) {
            if (!isFirst) Box(Modifier.width(2.dp).height(8.dp).background(if (isDone) MauveGray else Divider))
            Box(
                Modifier.size(28.dp).clip(CircleShape).background(if (isDone) MauveGray else SurfaceVariant),
                contentAlignment = Alignment.Center,
            ) {
                Icon(icon, null, tint = if (isDone) White else TextHint, modifier = Modifier.size(16.dp))
            }
            if (!isLast) Box(Modifier.width(2.dp).height(8.dp).background(if (isDone) MauveGray else Divider))
        }
        Spacer(Modifier.width(10.dp))
        Column(Modifier.weight(1f).padding(top = 4.dp)) {
            Text(label, style = MaterialTheme.typography.labelMedium.copy(
                color      = if (isDone) TextPrimary else TextHint,
                fontWeight = if (isDone) FontWeight.SemiBold else FontWeight.Normal,
            ))
            Text(detail, style = MaterialTheme.typography.labelSmall.copy(color = TextHint))
            if (!isLast) Spacer(Modifier.height(4.dp))
        }
    }
}
