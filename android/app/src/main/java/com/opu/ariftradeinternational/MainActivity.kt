package com.opu.ariftradeinternational

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.lifecycle.viewmodel.compose.viewModel
import com.opu.ariftradeinternational.navigation.AppNavigation
import com.opu.ariftradeinternational.ui.theme.ATITheme
import com.opu.ariftradeinternational.viewmodel.AppViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            ATITheme {
                val appViewModel: AppViewModel = viewModel()
                AppNavigation(viewModel = appViewModel)
            }
        }
    }
}