package com.opu.ariftradeinternational.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.opu.ariftradeinternational.data.model.QuotationStatus
import com.opu.ariftradeinternational.ui.theme.*

// ── Section header ─────────────────────────────────────────────────────────
@Composable
fun SectionHeader(
    title: String,
    modifier: Modifier = Modifier,
    action: (@Composable () -> Unit)? = null,
) {
    Row(
        modifier            = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment   = Alignment.CenterVertically,
    ) {
        Text(
            text  = title,
            style = MaterialTheme.typography.titleMedium.copy(
                color      = TextPrimary,
                fontWeight = FontWeight.SemiBold,
            ),
        )
        action?.invoke()
    }
}

// ── Gradient top header bar ────────────────────────────────────────────────
@Composable
fun GradientHeader(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit,
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(Brush.verticalGradient(listOf(GradientTop, GradientBottom))),
        content = content,
    )
}

// ── Screen top-bar for detail screens ─────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DetailTopBar(
    title: String,
    onBack: () -> Unit,
    actions: (@Composable RowScope.() -> Unit)? = null,
) {
    TopAppBar(
        title = {
            Text(
                text  = title,
                style = MaterialTheme.typography.titleLarge.copy(color = White),
            )
        },
        navigationIcon = {
            IconButton(onClick = onBack) {
                Icon(Icons.Filled.ArrowBackIosNew, contentDescription = "Back", tint = White)
            }
        },
        actions        = { actions?.invoke(this) },
        colors         = TopAppBarDefaults.topAppBarColors(
            containerColor = MauveGray,
        ),
    )
}

// ── Premium metric card ────────────────────────────────────────────────────
@Composable
fun MetricCard(
    label: String,
    value: String,
    icon:  ImageVector,
    cardColor: Color  = Surface,
    iconBg:    Color  = MauveLight,
    iconTint:  Color  = MauveGray,
    modifier:  Modifier = Modifier,
) {
    Card(
        modifier  = modifier,
        shape     = RoundedCornerShape(14.dp),
        colors    = CardDefaults.cardColors(containerColor = cardColor),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Column(
            modifier            = Modifier.padding(14.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Box(
                modifier        = Modifier.size(42.dp).clip(CircleShape).background(iconBg),
                contentAlignment = Alignment.Center,
            ) {
                Icon(icon, contentDescription = null, tint = iconTint, modifier = Modifier.size(22.dp))
            }
            Spacer(Modifier.height(8.dp))
            Text(value, style = MaterialTheme.typography.headlineSmall.copy(color = TextPrimary, fontWeight = FontWeight.Bold))
            Text(label, style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary), textAlign = TextAlign.Center)
        }
    }
}

// ── Action card (large tappable card) ─────────────────────────────────────
@Composable
fun ActionCard(
    title: String,
    subtitle: String,
    icon: ImageVector,
    gradient: List<Color>,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(
        modifier  = modifier.clickable(onClick = onClick),
        shape     = RoundedCornerShape(16.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 3.dp),
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .background(Brush.linearGradient(gradient))
                .padding(20.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    Modifier.size(52.dp).clip(CircleShape).background(White.copy(alpha = 0.18f)),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(icon, contentDescription = null, tint = White, modifier = Modifier.size(28.dp))
                }
                Spacer(Modifier.width(16.dp))
                Column {
                    Text(title,    style = MaterialTheme.typography.titleMedium.copy(color = White, fontWeight = FontWeight.Bold))
                    Text(subtitle, style = MaterialTheme.typography.bodySmall.copy(color = White.copy(alpha = 0.82f)))
                }
            }
        }
    }
}

// ── Product catalog card ───────────────────────────────────────────────────
@Composable
fun ProductCard(
    name: String,
    code: String,
    category: String,
    minPrice: Double,
    stockCount: Int,
    accentColor: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Card(
        modifier  = modifier.clickable(onClick = onClick),
        shape     = RoundedCornerShape(14.dp),
        colors    = CardDefaults.cardColors(containerColor = Surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Column {
            // Coloured top strip
            Box(
                Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .background(accentColor),
            )
            Column(Modifier.padding(12.dp)) {
                Text(
                    text     = category,
                    style    = MaterialTheme.typography.labelSmall.copy(color = accentColor, fontWeight = FontWeight.SemiBold),
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    text     = name,
                    style    = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold),
                    maxLines = 2,
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    text  = code,
                    style = MaterialTheme.typography.labelSmall.copy(color = TextHint),
                )
                Spacer(Modifier.height(8.dp))
                Text(
                    text  = "PKR ${"%,.0f".format(minPrice)}+",
                    style = MaterialTheme.typography.labelMedium.copy(color = MauveGray, fontWeight = FontWeight.Bold),
                )
                Spacer(Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier.size(7.dp).clip(CircleShape)
                            .background(if (stockCount > 10) StatusAccepted else if (stockCount > 0) StatusPending else StatusRejected),
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text  = if (stockCount > 0) "In stock" else "Out of stock",
                        style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary),
                    )
                }
            }
        }
    }
}

// ── Quotation status badge ─────────────────────────────────────────────────
@Composable
fun StatusBadge(status: QuotationStatus, modifier: Modifier = Modifier) {
    val (textColor, bgColor) = when (status) {
        QuotationStatus.PENDING  -> StatusPending  to StatusPendingBg
        QuotationStatus.ACCEPTED -> StatusAccepted to StatusAcceptedBg
        QuotationStatus.REJECTED -> StatusRejected to StatusRejectedBg
        QuotationStatus.RETURNED -> StatusReturned to StatusReturnedBg
    }
    Surface(
        modifier = modifier,
        shape    = RoundedCornerShape(20.dp),
        color    = bgColor,
    ) {
        Text(
            text     = status.label,
            style    = MaterialTheme.typography.labelSmall.copy(color = textColor, fontWeight = FontWeight.SemiBold),
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
        )
    }
}

// ── Quantity stepper ───────────────────────────────────────────────────────
@Composable
fun QuantityStepper(
    value: Int,
    onDecrement: () -> Unit,
    onIncrement: () -> Unit,
    min: Int = 1,
    max: Int = 999,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier          = modifier
            .clip(RoundedCornerShape(10.dp))
            .border(1.dp, Divider, RoundedCornerShape(10.dp)),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        IconButton(onClick = onDecrement, enabled = value > min, modifier = Modifier.size(38.dp)) {
            Icon(
                Icons.Filled.Remove, null,
                tint     = if (value > min) MauveGray else TextHint,
                modifier = Modifier.size(18.dp),
            )
        }
        Text(
            text     = value.toString(),
            style    = MaterialTheme.typography.titleMedium.copy(color = TextPrimary, fontWeight = FontWeight.Bold),
            modifier = Modifier.widthIn(min = 36.dp),
            textAlign = TextAlign.Center,
        )
        IconButton(onClick = onIncrement, enabled = value < max, modifier = Modifier.size(38.dp)) {
            Icon(
                Icons.Filled.Add, null,
                tint     = if (value < max) MauveGray else TextHint,
                modifier = Modifier.size(18.dp),
            )
        }
    }
}

// ── Customer type chip ─────────────────────────────────────────────────────
@Composable
fun CustomerTypeBadge(type: String, modifier: Modifier = Modifier) {
    val (label, color) = when (type.lowercase()) {
        "pharmacy"    -> "Pharmacy"    to Color(0xFF0891B2)
        "hospital"    -> "Hospital"    to Color(0xFF059669)
        "clinic"      -> "Clinic"      to Color(0xFF7C3AED)
        "distributor" -> "Distributor" to Color(0xFFD97706)
        else          -> type.replaceFirstChar { it.uppercase() } to MauveGray
    }
    Surface(
        modifier = modifier,
        shape    = RoundedCornerShape(6.dp),
        color    = color.copy(alpha = 0.12f),
    ) {
        Text(
            text     = label,
            style    = MaterialTheme.typography.labelSmall.copy(color = color, fontWeight = FontWeight.SemiBold),
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp),
        )
    }
}

// ── Empty state placeholder ────────────────────────────────────────────────
@Composable
fun EmptyState(
    icon: ImageVector,
    title: String,
    subtitle: String,
    modifier: Modifier = Modifier,
    action: (@Composable () -> Unit)? = null,
) {
    Column(
        modifier            = modifier.fillMaxWidth().padding(40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Icon(icon, null, tint = DustyRose, modifier = Modifier.size(64.dp))
        Spacer(Modifier.height(16.dp))
        Text(title,    style = MaterialTheme.typography.titleMedium.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold))
        Spacer(Modifier.height(6.dp))
        Text(subtitle, style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary), textAlign = TextAlign.Center)
        action?.let { Spacer(Modifier.height(20.dp)); it() }
    }
}

// ── Horizontal divider with label ─────────────────────────────────────────
@Composable
fun LabeledDivider(label: String, modifier: Modifier = Modifier) {
    Row(
        modifier       = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        HorizontalDivider(Modifier.weight(1f), color = Divider)
        Text(
            text     = "  $label  ",
            style    = MaterialTheme.typography.labelSmall.copy(color = TextHint),
        )
        HorizontalDivider(Modifier.weight(1f), color = Divider)
    }
}

// ── Category colour helper ─────────────────────────────────────────────────
fun categoryColor(categoryName: String): Color = when {
    categoryName.contains("Surgical",   ignoreCase = true) -> CatColorSurgical
    categoryName.contains("Diagnostic", ignoreCase = true) -> CatColorDiagnostic
    categoryName.contains("Consumable", ignoreCase = true) -> CatColorConsumable
    categoryName.contains("Ortho",      ignoreCase = true) -> CatColorOrthopaedic
    categoryName.contains("Cardio",     ignoreCase = true) -> CatColorCardiology
    else                                                    -> CatColorDefault
}

// ── Price formatter ────────────────────────────────────────────────────────
fun formatPKR(amount: Double): String = "PKR %,.0f".format(amount)
