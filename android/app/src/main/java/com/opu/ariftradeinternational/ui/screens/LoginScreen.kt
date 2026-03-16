package com.opu.ariftradeinternational.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusDirection
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.*
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.opu.ariftradeinternational.ui.theme.*
import com.opu.ariftradeinternational.viewmodel.AppViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    viewModel: AppViewModel,
    onLoginSuccess: () -> Unit,
) {
    var email       by remember { mutableStateOf("") }
    var password    by remember { mutableStateOf("") }
    var passVisible by remember { mutableStateOf(false) }

    val isLoading by viewModel.isLoading
    val loginError by viewModel.loginError
    val focusManager = LocalFocusManager.current

    LaunchedEffect(viewModel.isLoggedIn.value) {
        if (viewModel.isLoggedIn.value) onLoginSuccess()
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(CreamWhite),
    ) {
        // ── Gradient hero section ──────────────────────────────────────────
        Box(
            Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.50f)
                .background(Brush.verticalGradient(listOf(GradientTop, MauveGray))),
        ) {
            // Decorative circles
            Box(
                Modifier
                    .size(200.dp)
                    .align(Alignment.TopEnd)
                    .offset(x = 50.dp, y = (-40).dp)
                    .clip(CircleShape)
                    .background(White.copy(alpha = 0.06f)),
            )
            Box(
                Modifier
                    .size(120.dp)
                    .align(Alignment.BottomStart)
                    .offset(x = (-30).dp, y = 30.dp)
                    .clip(CircleShape)
                    .background(White.copy(alpha = 0.08f)),
            )

            // Logo + title
            Column(
                Modifier
                    .align(Alignment.Center)
                    .padding(horizontal = 32.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Box(
                    Modifier
                        .size(80.dp)
                        .clip(CircleShape)
                        .background(White.copy(alpha = 0.18f))
                        .border(2.dp, White.copy(alpha = 0.35f), CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        Icons.Filled.MedicalServices,
                        contentDescription = "ATI",
                        tint     = White,
                        modifier = Modifier.size(42.dp),
                    )
                }
                Spacer(Modifier.height(18.dp))
                Text(
                    "Arif Trade International",
                    style = MaterialTheme.typography.headlineMedium.copy(
                        color      = White,
                        fontWeight = FontWeight.Bold,
                    ),
                    textAlign = TextAlign.Center,
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    "Sales Portal",
                    style = MaterialTheme.typography.bodyLarge.copy(color = White.copy(alpha = 0.80f)),
                )
            }
        }

        // ── Form card slides up from bottom ───────────────────────────────
        Card(
            Modifier
                .fillMaxWidth()
                .align(Alignment.BottomCenter)
                .fillMaxHeight(0.58f),
            shape  = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
            colors = CardDefaults.cardColors(containerColor = Surface),
            elevation = CardDefaults.cardElevation(defaultElevation = 12.dp),
        ) {
            Column(
                Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 28.dp, vertical = 32.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text(
                    "Welcome Back",
                    style = MaterialTheme.typography.headlineSmall.copy(
                        color = TextPrimary, fontWeight = FontWeight.Bold,
                    ),
                )
                Spacer(Modifier.height(4.dp))
                Text(
                    "Sign in to your sales account",
                    style = MaterialTheme.typography.bodyMedium.copy(color = TextSecondary),
                )

                Spacer(Modifier.height(28.dp))

                // Email field
                OutlinedTextField(
                    value         = email,
                    onValueChange = { email = it },
                    label         = { Text("Email Address") },
                    leadingIcon   = { Icon(Icons.Outlined.Email, null, tint = MauveGray) },
                    singleLine    = true,
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Email,
                        imeAction    = ImeAction.Next,
                    ),
                    keyboardActions = KeyboardActions(
                        onNext = { focusManager.moveFocus(FocusDirection.Down) },
                    ),
                    modifier = Modifier.fillMaxWidth(),
                    shape    = RoundedCornerShape(12.dp),
                    colors   = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor   = MauveGray,
                        focusedLabelColor    = MauveGray,
                        cursorColor          = MauveGray,
                        unfocusedBorderColor = Divider,
                        unfocusedLabelColor  = TextHint,
                    ),
                )

                Spacer(Modifier.height(14.dp))

                // Password field
                OutlinedTextField(
                    value         = password,
                    onValueChange = { password = it },
                    label         = { Text("Password") },
                    leadingIcon   = { Icon(Icons.Outlined.Lock, null, tint = MauveGray) },
                    trailingIcon  = {
                        IconButton(onClick = { passVisible = !passVisible }) {
                            Icon(
                                if (passVisible) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                                null, tint = TextHint,
                            )
                        }
                    },
                    visualTransformation = if (passVisible) VisualTransformation.None else PasswordVisualTransformation(),
                    singleLine  = true,
                    keyboardOptions = KeyboardOptions(
                        keyboardType = KeyboardType.Password,
                        imeAction    = ImeAction.Done,
                    ),
                    keyboardActions = KeyboardActions(
                        onDone = {
                            focusManager.clearFocus()
                            if (email.isNotBlank() && password.isNotBlank())
                                viewModel.login(email.trim(), password)
                        },
                    ),
                    modifier = Modifier.fillMaxWidth(),
                    shape    = RoundedCornerShape(12.dp),
                    colors   = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor   = MauveGray,
                        focusedLabelColor    = MauveGray,
                        cursorColor          = MauveGray,
                        unfocusedBorderColor = Divider,
                        unfocusedLabelColor  = TextHint,
                    ),
                )

                // Error message
                AnimatedVisibility(visible = loginError != null) {
                    loginError?.let { err ->
                        Spacer(Modifier.height(8.dp))
                        Row(
                            Modifier
                                .fillMaxWidth()
                                .clip(RoundedCornerShape(8.dp))
                                .background(StatusRejectedBg)
                                .padding(10.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Icon(Icons.Filled.ErrorOutline, null, tint = StatusRejected, modifier = Modifier.size(16.dp))
                            Spacer(Modifier.width(6.dp))
                            Text(err, style = MaterialTheme.typography.bodySmall.copy(color = StatusRejected))
                        }
                    }
                }

                Spacer(Modifier.height(28.dp))

                // Sign-in button
                Button(
                    onClick  = {
                        focusManager.clearFocus()
                        viewModel.login(email.trim(), password)
                    },
                    enabled  = email.isNotBlank() && password.isNotBlank() && !isLoading,
                    modifier = Modifier.fillMaxWidth().height(52.dp),
                    shape    = RoundedCornerShape(14.dp),
                    colors   = ButtonDefaults.buttonColors(
                        containerColor = MauveGray,
                        disabledContainerColor = MauveGray.copy(alpha = 0.45f),
                    ),
                ) {
                    if (isLoading) {
                        CircularProgressIndicator(
                            modifier    = Modifier.size(22.dp),
                            color       = White,
                            strokeWidth = 2.5.dp,
                        )
                    } else {
                        Text(
                            "Sign In",
                            style = MaterialTheme.typography.labelLarge.copy(color = White),
                        )
                    }
                }

                Spacer(Modifier.height(20.dp))
                Row(
                    Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment     = Alignment.CenterVertically,
                ) {
                    Icon(Icons.Filled.AdminPanelSettings, null, tint = TextHint, modifier = Modifier.size(14.dp))
                    Spacer(Modifier.width(5.dp))
                    Text(
                        "Accounts are created by your administrator",
                        style = MaterialTheme.typography.bodySmall.copy(color = TextHint),
                    )
                }
            }
        }
    }
}
