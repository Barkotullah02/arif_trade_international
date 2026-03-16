package com.opu.ariftradeinternational.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
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
import com.opu.ariftradeinternational.data.model.QuotationStatus
import com.opu.ariftradeinternational.navigation.Screen
import com.opu.ariftradeinternational.ui.components.*
import com.opu.ariftradeinternational.ui.theme.*
import com.opu.ariftradeinternational.viewmodel.AppViewModel

@Composable
fun DashboardScreen(viewModel: AppViewModel, navController: NavController) {
    val user       = viewModel.currentUser.value
    val quotations = viewModel.quotations

    LaunchedEffect(Unit) {
        if (quotations.isEmpty()) viewModel.loadQuotations()
    }

    val todayCount    = quotations.count { it.createdAt == "2026-03-08" }
    val pendingCount  = quotations.count { it.status == QuotationStatus.PENDING }
    val acceptedCount = quotations.count { it.status == QuotationStatus.ACCEPTED }

    Column(
        Modifier
            .fillMaxSize()
            .background(CreamWhite)
            .verticalScroll(rememberScrollState()),
    ) {
        // ── Gradient header ────────────────────────────────────────────────
        Box(
            Modifier
                .fillMaxWidth()
                .background(Brush.verticalGradient(listOf(GradientTop, MauveGray)))
                .padding(horizontal = 20.dp)
                .padding(top = 52.dp, bottom = 28.dp),
        ) {
            Column {
                Row(
                    Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment     = Alignment.CenterVertically,
                ) {
                    Column {
                        Text(
                            text  = "Good Morning 👋",
                            style = MaterialTheme.typography.bodyMedium.copy(color = White.copy(alpha = 0.80f)),
                        )
                        Spacer(Modifier.height(2.dp))
                        Text(
                            text  = user?.name ?: "Salesman",
                            style = MaterialTheme.typography.headlineMedium.copy(
                                color = White, fontWeight = FontWeight.Bold,
                            ),
                        )
                        Spacer(Modifier.height(6.dp))
                        Surface(
                            shape = RoundedCornerShape(20.dp),
                            color = White.copy(alpha = 0.18f),
                        ) {
                            Text(
                                text     = "Sales Representative",
                                style    = MaterialTheme.typography.labelSmall.copy(color = White),
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                            )
                        }
                    }
                    // Avatar
                    Box(
                        Modifier
                            .size(52.dp)
                            .clip(CircleShape)
                            .background(White.copy(alpha = 0.18f))
                            .border(2.dp, White.copy(alpha = 0.35f), CircleShape),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text(
                            text  = user?.name?.take(1)?.uppercase() ?: "A",
                            style = MaterialTheme.typography.headlineMedium.copy(
                                color = White, fontWeight = FontWeight.Bold,
                            ),
                        )
                    }
                }

                Spacer(Modifier.height(20.dp))

                // Quick date display
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Outlined.CalendarToday, null, tint = White.copy(alpha = 0.70f), modifier = Modifier.size(14.dp))
                    Spacer(Modifier.width(5.dp))
                    Text(
                        text  = "Sunday, 8 March 2026",
                        style = MaterialTheme.typography.bodySmall.copy(color = White.copy(alpha = 0.75f)),
                    )
                }
            }
        }

        // ── Stats row ──────────────────────────────────────────────────────
        Row(
            Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp)
                .offset(y = (-20).dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
        ) {
            MetricCard(
                label     = "Today",
                value     = "$todayCount",
                icon      = Icons.Outlined.Today,
                modifier  = Modifier.weight(1f),
                iconBg    = MauveLight,
                iconTint  = MauveGray,
            )
            MetricCard(
                label    = "Pending",
                value    = "$pendingCount",
                icon     = Icons.Outlined.HourglassTop,
                modifier = Modifier.weight(1f),
                iconBg   = StatusPendingBg,
                iconTint = StatusPending,
            )
            MetricCard(
                label    = "Accepted",
                value    = "$acceptedCount",
                icon     = Icons.Outlined.TaskAlt,
                modifier = Modifier.weight(1f),
                iconBg   = StatusAcceptedBg,
                iconTint = StatusAccepted,
            )
        }

        // ── Quick actions ──────────────────────────────────────────────────
        Column(Modifier.padding(horizontal = 16.dp).offset(y = (-8).dp)) {
            SectionHeader("Quick Actions")
            Spacer(Modifier.height(10.dp))

            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                ActionCard(
                    title    = "New Quotation Request",
                    subtitle = "Choose customer, products & submit",
                    icon     = Icons.Filled.NoteAdd,
                    gradient = listOf(GradientTop, MauveGray),
                    onClick  = { navController.navigate(Screen.CreateQuotation.route) },
                    modifier = Modifier.fillMaxWidth(),
                )
                ActionCard(
                    title    = "Browse Product Catalog",
                    subtitle = "Search & explore available products",
                    icon     = Icons.Filled.Inventory2,
                    gradient = listOf(DustyRoseDark, DustyRose),
                    onClick  = { navController.navigate(Screen.Catalog.route) },
                    modifier = Modifier.fillMaxWidth(),
                )
            }

            Spacer(Modifier.height(24.dp))

            // ── Recent quotations ──────────────────────────────────────────
            SectionHeader(
                title  = "Recent Quotations",
                action = {
                    TextButton(onClick = { navController.navigate(Screen.QuotationHistory.route) }) {
                        Text("View All", style = MaterialTheme.typography.labelMedium.copy(color = MauveGray))
                    }
                },
            )
            Spacer(Modifier.height(10.dp))
        }

        if (quotations.isEmpty()) {
            EmptyState(
                icon     = Icons.Outlined.Receipt,
                title    = "No quotations yet",
                subtitle = "Tap New Quotation above to create your first",
                modifier = Modifier.padding(horizontal = 16.dp),
            )
        } else {
            LazyRow(
                contentPadding       = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(quotations.take(5)) { q ->
                    RecentQuotationCard(
                        customerName = q.customerName,
                        customerType = q.customerType,
                        date         = q.createdAt,
                        total        = q.grandTotal,
                        itemCount    = q.items.size,
                        status       = q.status,
                        onClick      = { navController.navigate(Screen.QuotationDetail.createRoute(q.id)) },
                    )
                }
            }
        }

        Spacer(Modifier.height(24.dp))

        // ── Logout button (bottom of scroll) ──────────────────────────────
        Column(Modifier.padding(horizontal = 16.dp)) {
            HorizontalDivider(color = Divider)
            Spacer(Modifier.height(12.dp))
            OutlinedButton(
                onClick = { viewModel.logout() },
                modifier = Modifier.fillMaxWidth(),
                shape    = RoundedCornerShape(12.dp),
                border   = BorderStroke(1.dp, DustyRose),
            ) {
                Icon(Icons.Outlined.Logout, null, tint = DustyRoseDark, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text("Sign Out", style = MaterialTheme.typography.labelLarge.copy(color = DustyRoseDark))
            }
            Spacer(Modifier.height(16.dp))
        }
    }
}

// ── Recent quotation horizontal card ──────────────────────────────────────
@Composable
private fun RecentQuotationCard(
    customerName: String,
    customerType: String,
    date: String,
    total: Double,
    itemCount: Int,
    status: QuotationStatus,
    onClick: () -> Unit,
) {
    Card(
        modifier  = Modifier.width(220.dp).clickable(onClick = onClick),
        shape     = RoundedCornerShape(14.dp),
        colors    = CardDefaults.cardColors(containerColor = Surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Column(Modifier.padding(14.dp)) {
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.Top,
            ) {
                Column(Modifier.weight(1f)) {
                    Text(
                        text     = customerName,
                        style    = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold),
                        maxLines = 1,
                    )
                    CustomerTypeBadge(type = customerType, modifier = Modifier.padding(top = 3.dp))
                }
                StatusBadge(status = status)
            }
            Spacer(Modifier.height(12.dp))
            HorizontalDivider(color = Divider)
            Spacer(Modifier.height(10.dp))
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Column {
                    Text("Total", style = MaterialTheme.typography.labelSmall.copy(color = TextHint))
                    Text(
                        formatPKR(total),
                        style = MaterialTheme.typography.titleSmall.copy(color = MauveGray, fontWeight = FontWeight.Bold),
                    )
                }
                Column(horizontalAlignment = Alignment.End) {
                    Text("Items", style = MaterialTheme.typography.labelSmall.copy(color = TextHint))
                    Text(
                        "$itemCount",
                        style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.Bold),
                    )
                }
            }
            Spacer(Modifier.height(8.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Outlined.CalendarToday, null, tint = TextHint, modifier = Modifier.size(12.dp))
                Spacer(Modifier.width(4.dp))
                Text(date, style = MaterialTheme.typography.labelSmall.copy(color = TextHint))
            }
        }
    }
}
