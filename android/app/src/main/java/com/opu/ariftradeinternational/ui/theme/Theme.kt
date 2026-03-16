package com.opu.ariftradeinternational.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val ATIColorScheme = lightColorScheme(
    primary              = MauveGray,
    onPrimary            = White,
    primaryContainer     = MauveLight,
    onPrimaryContainer   = MauveDeep,
    secondary            = DustyRose,
    onSecondary          = White,
    secondaryContainer   = DustyRoseLight,
    onSecondaryContainer = DustyRoseDark,
    background           = CreamWhite,
    onBackground         = TextPrimary,
    surface              = Surface,
    onSurface            = TextPrimary,
    surfaceVariant       = SurfaceVariant,
    onSurfaceVariant     = TextSecondary,
    outline              = DustyRose,
    outlineVariant       = Divider,
    error                = StatusRejected,
    onError              = White,
    scrim                = Scrim,
)

@Composable
fun ATITheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = ATIColorScheme,
        typography  = ATITypography,
        content     = content,
    )
}
