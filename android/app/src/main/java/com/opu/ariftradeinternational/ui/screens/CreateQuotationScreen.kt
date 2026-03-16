package com.opu.ariftradeinternational.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.opu.ariftradeinternational.data.model.Customer
import com.opu.ariftradeinternational.data.model.QuotationDraftItem
import com.opu.ariftradeinternational.navigation.Screen
import com.opu.ariftradeinternational.ui.components.*
import com.opu.ariftradeinternational.ui.theme.*
import com.opu.ariftradeinternational.viewmodel.AppViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreateQuotationScreen(viewModel: AppViewModel, navController: NavController) {
    var customerSearch by remember { mutableStateOf("") }
    var showCustomerSheet by remember { mutableStateOf(false) }
    var submitted by remember { mutableStateOf(false) }
    var showConfirmDialog by remember { mutableStateOf(false) }
    var submitError by remember { mutableStateOf<String?>(null) }

    val selectedCustomer by viewModel.selectedCustomer
    val draftItems       = viewModel.draftItems
    var note by viewModel.quotationNote

    val allCustomers = viewModel.customers

    LaunchedEffect(Unit) {
        if (allCustomers.isEmpty()) viewModel.loadCustomers()
    }

    val filteredCustomers = allCustomers.filter {
        customerSearch.isBlank() ||
            it.name.contains(customerSearch, ignoreCase = true) ||
            it.type.contains(customerSearch, ignoreCase = true) ||
            it.phone.contains(customerSearch)
    }

    if (submitted) {
        SubmissionSuccessScreen(onDone = {
            navController.navigate(Screen.QuotationHistory.route) {
                popUpTo(Screen.Dashboard.route)
            }
        })
        return
    }

    // ── Customer picker bottom sheet ───────────────────────────────────────
    if (showCustomerSheet) {
        ModalBottomSheet(
            onDismissRequest = { showCustomerSheet = false; customerSearch = "" },
            containerColor   = Surface,
            shape            = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp),
        ) {
            Column(Modifier.padding(horizontal = 16.dp).padding(bottom = 32.dp)) {
                Text(
                    "Select Customer / Doctor",
                    style    = MaterialTheme.typography.titleLarge.copy(color = TextPrimary, fontWeight = FontWeight.Bold),
                    modifier = Modifier.padding(bottom = 14.dp),
                )
                OutlinedTextField(
                    value         = customerSearch,
                    onValueChange = { customerSearch = it },
                    placeholder   = { Text("Search by name, type or phone…") },
                    leadingIcon   = { Icon(Icons.Outlined.Search, null, tint = MauveGray) },
                    singleLine    = true,
                    modifier      = Modifier.fillMaxWidth(),
                    shape         = RoundedCornerShape(10.dp),
                    colors        = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor   = MauveGray,
                        unfocusedBorderColor = Divider,
                    ),
                )
                Spacer(Modifier.height(12.dp))
                LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(filteredCustomers) { customer ->
                        CustomerRow(
                            customer  = customer,
                            isSelected = selectedCustomer?.id == customer.id,
                            onClick = {
                                viewModel.selectedCustomer.value = customer
                                showCustomerSheet = false
                                customerSearch    = ""
                            },
                        )
                    }
                }
            }
        }
    }

    // ── Submit confirm dialog ──────────────────────────────────────────────
    if (showConfirmDialog) {
        AlertDialog(
            onDismissRequest = { showConfirmDialog = false },
            icon     = { Icon(Icons.Outlined.Send, null, tint = MauveGray) },
            title    = { Text("Submit Quotation?") },
            text     = {
                Text(
                    "Send quotation request for ${selectedCustomer?.name} with ${draftItems.size} line item(s) totaling ${formatPKR(viewModel.draftTotal)}?",
                    style = MaterialTheme.typography.bodyMedium.copy(color = TextSecondary),
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        showConfirmDialog = false
                        viewModel.submitQuotation { ok, error ->
                            submitError = error
                            if (ok) submitted = true
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MauveGray),
                ) { Text("Submit") }
            },
            dismissButton = {
                OutlinedButton(onClick = { showConfirmDialog = false }) { Text("Cancel") }
            },
        )
    }

    Scaffold(
        topBar = {
            DetailTopBar(
                title  = "New Quotation",
                onBack = { navController.popBackStack() },
            )
        },
        bottomBar = {
            Surface(shadowElevation = 8.dp, color = Surface) {
                Column(
                    Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                        .navigationBarsPadding(),
                ) {
                    if (draftItems.isNotEmpty() && selectedCustomer != null) {
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(10.dp))
                                .background(MauveLight)
                                .padding(12.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text("Grand Total", style = MaterialTheme.typography.titleSmall.copy(color = TextSecondary))
                            Text(
                                formatPKR(viewModel.draftTotal),
                                style = MaterialTheme.typography.titleMedium.copy(color = MauveGray, fontWeight = FontWeight.Bold),
                            )
                        }
                        Spacer(Modifier.height(10.dp))
                    }
                    submitError?.let {
                        Text(
                            text = it,
                            color = StatusRejected,
                            style = MaterialTheme.typography.bodySmall,
                            modifier = Modifier.padding(bottom = 8.dp),
                        )
                    }
                    Button(
                        onClick  = { showConfirmDialog = true },
                        enabled  = selectedCustomer != null && draftItems.isNotEmpty(),
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape    = RoundedCornerShape(14.dp),
                        colors   = ButtonDefaults.buttonColors(
                            containerColor         = MauveGray,
                            disabledContainerColor = MauveGray.copy(alpha = 0.35f),
                        ),
                    ) {
                        Icon(Icons.Filled.Send, null, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Submit Quotation Request", style = MaterialTheme.typography.labelLarge.copy(color = White))
                    }
                }
            }
        },
    ) { innerPadding ->
        LazyColumn(
            Modifier
                .fillMaxSize()
                .background(CreamWhite)
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            // ── Step 1: Customer selection ─────────────────────────────────
            item {
                Card(
                    shape  = RoundedCornerShape(14.dp),
                    colors = CardDefaults.cardColors(containerColor = Surface),
                    elevation = CardDefaults.cardElevation(2.dp),
                ) {
                    Column(Modifier.padding(16.dp)) {
                        StepLabel(number = "1", label = "Customer / Doctor")
                        Spacer(Modifier.height(12.dp))

                        if (selectedCustomer == null) {
                            OutlinedButton(
                                onClick  = { showCustomerSheet = true },
                                modifier = Modifier.fillMaxWidth().height(50.dp),
                                shape    = RoundedCornerShape(12.dp),
                                border   = BorderStroke(1.5.dp, DustyRose),
                            ) {
                                Icon(Icons.Outlined.PersonSearch, null, tint = MauveGray)
                                Spacer(Modifier.width(8.dp))
                                Text("Select Customer / Doctor", style = MaterialTheme.typography.labelLarge.copy(color = MauveGray))
                            }
                        } else {
                            SelectedCustomerCard(
                                customer = selectedCustomer!!,
                                onClear  = { viewModel.selectedCustomer.value = null },
                                onEdit   = { showCustomerSheet = true },
                            )
                        }
                    }
                }
            }

            // ── Step 2: Products ───────────────────────────────────────────
            item {
                Card(
                    shape  = RoundedCornerShape(14.dp),
                    colors = CardDefaults.cardColors(containerColor = Surface),
                    elevation = CardDefaults.cardElevation(2.dp),
                ) {
                    Column(Modifier.padding(16.dp)) {
                        Row(
                            Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment     = Alignment.CenterVertically,
                        ) {
                            StepLabel(number = "2", label = "Products (${draftItems.size})")
                            TextButton(onClick = { navController.navigate(Screen.Catalog.route) }) {
                                Icon(Icons.Outlined.Add, null, tint = MauveGray, modifier = Modifier.size(16.dp))
                                Spacer(Modifier.width(4.dp))
                                Text("Add Product", style = MaterialTheme.typography.labelMedium.copy(color = MauveGray))
                            }
                        }

                        if (draftItems.isEmpty()) {
                            Spacer(Modifier.height(8.dp))
                            EmptyState(
                                icon     = Icons.Outlined.AddShoppingCart,
                                title    = "No products added",
                                subtitle = "Browse the catalog to add products",
                            )
                        }
                    }
                }
            }

            // ── Draft line items ───────────────────────────────────────────
            items(draftItems, key = { it.variantUnit.id }) { item ->
                DraftItemCard(
                    item     = item,
                    onQtyChange  = { viewModel.updateDraftQty(item.variantUnit.id, it) },
                    onRemove = { viewModel.removeDraftItem(item.variantUnit.id) },
                )
            }

            // ── Step 3: Note ───────────────────────────────────────────────
            item {
                Card(
                    shape  = RoundedCornerShape(14.dp),
                    colors = CardDefaults.cardColors(containerColor = Surface),
                    elevation = CardDefaults.cardElevation(2.dp),
                ) {
                    Column(Modifier.padding(16.dp)) {
                        StepLabel(number = "3", label = "Note (Optional)")
                        Spacer(Modifier.height(10.dp))
                        OutlinedTextField(
                            value         = note,
                            onValueChange = { viewModel.quotationNote.value = it },
                            placeholder   = { Text("Add any special instructions, delivery notes…") },
                            modifier      = Modifier.fillMaxWidth(),
                            shape         = RoundedCornerShape(10.dp),
                            minLines      = 3,
                            colors        = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor   = MauveGray,
                                unfocusedBorderColor = Divider,
                            ),
                        )
                    }
                }
            }

            item { Spacer(Modifier.height(80.dp)) }
        }
    }
}

// ── Sub-composables ────────────────────────────────────────────────────────
@Composable
private fun StepLabel(number: String, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            Modifier.size(26.dp).clip(CircleShape).background(MauveGray),
            contentAlignment = Alignment.Center,
        ) {
            Text(number, style = MaterialTheme.typography.labelMedium.copy(color = White, fontWeight = FontWeight.Bold))
        }
        Spacer(Modifier.width(8.dp))
        Text(label, style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold))
    }
}

@Composable
private fun CustomerRow(customer: Customer, isSelected: Boolean, onClick: () -> Unit) {
    Surface(
        modifier  = Modifier.fillMaxWidth().clickable(onClick = onClick),
        shape     = RoundedCornerShape(10.dp),
        color     = if (isSelected) MauveLight else SurfaceVariant,
        border    = if (isSelected) BorderStroke(1.dp, MauveGray) else null,
    ) {
        Row(
            Modifier.padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                Modifier.size(40.dp).clip(CircleShape).background(if (isSelected) MauveGray else DustyRoseLight),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    customer.name.take(1).uppercase(),
                    style = MaterialTheme.typography.titleSmall.copy(
                        color = if (isSelected) White else MauveGray, fontWeight = FontWeight.Bold,
                    ),
                )
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(customer.name, style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold))
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    CustomerTypeBadge(customer.type)
                    Text(customer.phone, style = MaterialTheme.typography.labelSmall.copy(color = TextHint))
                }
            }
            if (isSelected) Icon(Icons.Filled.CheckCircle, null, tint = MauveGray, modifier = Modifier.size(20.dp))
        }
    }
}

@Composable
private fun SelectedCustomerCard(customer: Customer, onClear: () -> Unit, onEdit: () -> Unit) {
    Surface(
        shape = RoundedCornerShape(12.dp),
        color = MauveLight,
        border = BorderStroke(1.dp, MauveGray.copy(alpha = 0.40f)),
    ) {
        Row(
            Modifier.fillMaxWidth().padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Box(
                Modifier.size(44.dp).clip(CircleShape).background(MauveGray),
                contentAlignment = Alignment.Center,
            ) {
                Text(customer.name.take(1).uppercase(), style = MaterialTheme.typography.titleMedium.copy(color = White, fontWeight = FontWeight.Bold))
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(customer.name, style = MaterialTheme.typography.titleSmall.copy(color = MauveDeep, fontWeight = FontWeight.Bold))
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    CustomerTypeBadge(customer.type)
                }
                Text(customer.phone, style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary))
                customer.address?.let { Text(it, style = MaterialTheme.typography.labelSmall.copy(color = TextHint), maxLines = 1) }
            }
            IconButton(onClick = onEdit) { Icon(Icons.Outlined.Edit, null, tint = MauveGray, modifier = Modifier.size(18.dp)) }
            IconButton(onClick = onClear) { Icon(Icons.Outlined.Close, null, tint = StatusRejected, modifier = Modifier.size(18.dp)) }
        }
    }
}

@Composable
private fun DraftItemCard(
    item: QuotationDraftItem,
    onQtyChange: (Int) -> Unit,
    onRemove: () -> Unit,
) {
    Card(
        shape     = RoundedCornerShape(12.dp),
        colors    = CardDefaults.cardColors(containerColor = Surface),
        elevation = CardDefaults.cardElevation(1.dp),
    ) {
        Column(Modifier.padding(14.dp)) {
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.Top,
            ) {
                Column(Modifier.weight(1f)) {
                    Text(item.productName, style = MaterialTheme.typography.titleSmall.copy(color = TextPrimary, fontWeight = FontWeight.SemiBold))
                    Text(
                        "${item.variantSku}  ·  ${item.variantUnit.unitName}",
                        style = MaterialTheme.typography.labelSmall.copy(color = TextSecondary),
                    )
                }
                IconButton(onClick = onRemove, modifier = Modifier.size(30.dp)) {
                    Icon(Icons.Outlined.DeleteOutline, null, tint = StatusRejected, modifier = Modifier.size(18.dp))
                }
            }
            Spacer(Modifier.height(10.dp))
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.CenterVertically,
            ) {
                QuantityStepper(
                    value       = item.quantity,
                    onDecrement = { onQtyChange(item.quantity - 1) },
                    onIncrement = { onQtyChange(item.quantity + 1) },
                )
                Column(horizontalAlignment = Alignment.End) {
                    Text(formatPKR(item.variantUnit.unitPrice) + " / unit", style = MaterialTheme.typography.labelSmall.copy(color = TextHint))
                    Text(formatPKR(item.lineTotal), style = MaterialTheme.typography.titleSmall.copy(color = MauveGray, fontWeight = FontWeight.Bold))
                }
            }
        }
    }
}

@Composable
private fun SubmissionSuccessScreen(onDone: () -> Unit) {
    Box(Modifier.fillMaxSize().background(CreamWhite), contentAlignment = Alignment.Center) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier            = Modifier.padding(40.dp),
        ) {
            Box(
                Modifier.size(96.dp).clip(CircleShape).background(StatusAcceptedBg),
                contentAlignment = Alignment.Center,
            ) {
                Icon(Icons.Filled.CheckCircle, null, tint = StatusAccepted, modifier = Modifier.size(56.dp))
            }
            Spacer(Modifier.height(24.dp))
            Text("Quotation Submitted!", style = MaterialTheme.typography.headlineSmall.copy(color = TextPrimary, fontWeight = FontWeight.Bold))
            Spacer(Modifier.height(8.dp))
            Text(
                "Your quotation request has been submitted successfully and is pending review.",
                style    = MaterialTheme.typography.bodyMedium.copy(color = TextSecondary),
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(32.dp))
            Button(
                onClick  = onDone,
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape    = RoundedCornerShape(14.dp),
                colors   = ButtonDefaults.buttonColors(containerColor = MauveGray),
            ) {
                Text("View Quotation History", style = MaterialTheme.typography.labelLarge.copy(color = White))
            }
        }
    }
}
