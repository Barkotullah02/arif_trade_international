package com.opu.ariftradeinternational.data.mock

import com.opu.ariftradeinternational.data.model.*

object MockData {

    val currentUser = User(1, "Ali Hassan", "ali@ati.local", "salesman")

    val categories = listOf(
        Category(1, "Surgical Instruments"),
        Category(2, "Diagnostic Equipment"),
        Category(3, "Consumables"),
        Category(4, "Orthopaedic"),
        Category(5, "Cardiology"),
    )

    val products = listOf(
        Product(
            id = 1, name = "Digital Stethoscope Pro", productCode = "DSP-001",
            categoryId = 2, categoryName = "Diagnostic Equipment",
            description = "High-fidelity digital stethoscope with ambient noise reduction and Bluetooth connectivity for seamless device integration.",
            isActive = true,
            variants = listOf(
                ProductVariant(
                    id = 1, productId = 1, sku = "DSP-001-STD",
                    attributes = mapOf("Model" to "Standard"),
                    units = listOf(
                        VariantUnit(1, 1, 1, "Piece",       1.0,  45,  8_500.00),
                        VariantUnit(2, 1, 2, "Box (5 pcs)", 5.0,   8, 40_000.00),
                    ),
                ),
            ),
        ),
        Product(
            id = 2, name = "Surgical Scalpel Set", productCode = "SSS-002",
            categoryId = 1, categoryName = "Surgical Instruments",
            description = "Sterile stainless-steel scalpel set, sizes 10–22, individually packed. Meets ISO 7740 standards.",
            isActive = true,
            variants = listOf(
                ProductVariant(
                    id = 2, productId = 2, sku = "SSS-002-SS",
                    attributes = mapOf("Material" to "Stainless Steel"),
                    units = listOf(
                        VariantUnit(3, 2, 1, "Set (12 pcs)",      12.0,  100,  1_200.00),
                        VariantUnit(4, 2, 3, "Carton (10 sets)", 120.0,   15, 11_000.00),
                    ),
                ),
            ),
        ),
        Product(
            id = 3, name = "Blood Pressure Monitor", productCode = "BPM-003",
            categoryId = 2, categoryName = "Diagnostic Equipment",
            description = "Fully automatic upper-arm BP monitor with irregular heartbeat detection, memory recall for 90 readings.",
            isActive = true,
            variants = listOf(
                ProductVariant(
                    id = 3, productId = 3, sku = "BPM-003-AUTO",
                    attributes = mapOf("Type" to "Digital Automatic"),
                    units = listOf(
                        VariantUnit(5, 3, 1, "Piece",      1.0, 60, 3_200.00),
                        VariantUnit(6, 3, 2, "Box (3 pcs)", 3.0, 20, 9_200.00),
                    ),
                ),
            ),
        ),
        Product(
            id = 4, name = "IV Cannula 22G", productCode = "IVC-004",
            categoryId = 3, categoryName = "Consumables",
            description = "Safety IV cannula 22G with injection port, individually sterile-packed and single use only.",
            isActive = true,
            variants = listOf(
                ProductVariant(
                    id = 4, productId = 4, sku = "IVC-004-22G",
                    attributes = mapOf("Gauge" to "22G"),
                    units = listOf(
                        VariantUnit(7,  4, 1, "Piece",              1.0,    500,     35.00),
                        VariantUnit(8,  4, 2, "Box (100 pcs)",    100.0,     50,  3_200.00),
                        VariantUnit(9,  4, 3, "Carton (10 boxes)", 1000.0,    5, 30_000.00),
                    ),
                ),
                ProductVariant(
                    id = 5, productId = 4, sku = "IVC-004-20G",
                    attributes = mapOf("Gauge" to "20G"),
                    units = listOf(
                        VariantUnit(10, 5, 1, "Piece",           1.0,  400,    40.00),
                        VariantUnit(11, 5, 2, "Box (100 pcs)", 100.0,   40, 3_600.00),
                    ),
                ),
            ),
        ),
        Product(
            id = 5, name = "Knee Brace Support", productCode = "KBS-005",
            categoryId = 4, categoryName = "Orthopaedic",
            description = "Adjustable knee support brace with lateral side stabilisers; ideal for post-injury rehabilitation.",
            isActive = true,
            variants = listOf(
                ProductVariant(
                    id = 6, productId = 5, sku = "KBS-005-SM",
                    attributes = mapOf("Size" to "S / M"),
                    units = listOf(VariantUnit(12, 6, 1, "Piece", 1.0, 30, 2_400.00)),
                ),
                ProductVariant(
                    id = 7, productId = 5, sku = "KBS-005-LXL",
                    attributes = mapOf("Size" to "L / XL"),
                    units = listOf(VariantUnit(13, 7, 1, "Piece", 1.0, 25, 2_600.00)),
                ),
            ),
        ),
        Product(
            id = 6, name = "ECG Machine 12-Lead", productCode = "ECG-006",
            categoryId = 5, categoryName = "Cardiology",
            description = "Portable 12-lead ECG with thermal print, USB export, and 7-inch capacitive touchscreen display.",
            isActive = true,
            variants = listOf(
                ProductVariant(
                    id = 8, productId = 6, sku = "ECG-006-PTB",
                    attributes = mapOf("Type" to "Portable"),
                    units = listOf(VariantUnit(14, 8, 1, "Unit", 1.0, 10, 185_000.00)),
                ),
            ),
        ),
        Product(
            id = 7, name = "Pulse Oximeter", productCode = "POX-007",
            categoryId = 2, categoryName = "Diagnostic Equipment",
            description = "Fingertip pulse oximeter with OLED display, SpO2 & pulse rate measurement, includes lanyard.",
            isActive = true,
            variants = listOf(
                ProductVariant(
                    id = 9, productId = 7, sku = "POX-007-STD",
                    attributes = mapOf("Display" to "OLED"),
                    units = listOf(
                        VariantUnit(15, 9, 1, "Piece",      1.0, 120,   950.00),
                        VariantUnit(16, 9, 2, "Box (10 pcs)", 10.0, 15, 8_800.00),
                    ),
                ),
            ),
        ),
        Product(
            id = 8, name = "Surgical Gloves (Latex)", productCode = "SGL-008",
            categoryId = 3, categoryName = "Consumables",
            description = "Sterile latex surgical gloves, powder-free, textured for grip. Sizes XS–XL available.",
            isActive = true,
            variants = listOf(
                ProductVariant(
                    id = 10, productId = 8, sku = "SGL-008-M",
                    attributes = mapOf("Size" to "Medium"),
                    units = listOf(
                        VariantUnit(17, 10, 2, "Box (50 pairs)", 50.0, 200, 1_400.00),
                        VariantUnit(18, 10, 3, "Carton (10 boxes)", 500.0, 20, 12_500.00),
                    ),
                ),
            ),
        ),
    )

    val customers = listOf(
        Customer(1, "Dr. Fatima Malik",   "clinic",      "0300-1234567", "fatima@clinic.pk",     "Street 5, Gulberg, Lahore"),
        Customer(2, "City Pharmacy",      "pharmacy",    "0311-1234567", "city@pharmacy.pk",     "Main Blvd, DHA Phase 4, Lahore"),
        Customer(3, "Services Hospital",  "hospital",    "042-35678901", null,                   "Jail Road, Lahore"),
        Customer(4, "Dr. Arif Shah",      "clinic",      "0333-5678901", "arif@medsuite.pk",     "Model Town, Lahore"),
        Customer(5, "MediCare Supplies",  "distributor", "0321-5678901", "info@medicare.pk",     "Ring Road, Faisalabad"),
        Customer(6, "Al-Shifa Pharmacy",  "pharmacy",    "0345-1234567", null,                   "Saddar, Rawalpindi"),
        Customer(7, "Dr. Nadia Hussain",  "clinic",      "0300-1112233", "nadia@care.pk",        "F-7 Markaz, Islamabad"),
        Customer(8, "Punjab Care Dist.",  "distributor", "042-1234567",  "orders@pcd.pk",        "Multan Road, Lahore"),
        Customer(9, "Aga Khan Hospital",  "hospital",    "021-11119988", "orders@aku.pk",        "Stadium Road, Karachi"),
        Customer(10, "Medix Pharma",      "pharmacy",    "0312-9876543", "medix@pharma.pk",      "Blue Area, Islamabad"),
    )

    val quotations = listOf(
        Quotation(
            id = 1, customerId = 1, customerName = "Dr. Fatima Malik", customerType = "clinic",
            items = listOf(
                QuotationItem(1,  "Digital Stethoscope Pro", "DSP-001-STD", "Piece",      2, 8_500.00),
                QuotationItem(5,  "Blood Pressure Monitor",  "BPM-003-AUTO","Piece",      1, 3_200.00),
            ),
            status = QuotationStatus.ACCEPTED, note = "Urgent delivery requested.", createdAt = "2026-03-01",
        ),
        Quotation(
            id = 2, customerId = 2, customerName = "City Pharmacy", customerType = "pharmacy",
            items = listOf(
                QuotationItem(8, "IV Cannula 22G", "IVC-004-22G", "Box (100 pcs)", 5, 3_200.00),
            ),
            status = QuotationStatus.PENDING, note = "", createdAt = "2026-03-04",
        ),
        Quotation(
            id = 3, customerId = 3, customerName = "Services Hospital", customerType = "hospital",
            items = listOf(
                QuotationItem(14, "ECG Machine 12-Lead", "ECG-006-PTB", "Unit", 1, 185_000.00),
            ),
            status = QuotationStatus.PENDING, note = "Please include training session.", createdAt = "2026-03-06",
        ),
        Quotation(
            id = 4, customerId = 4, customerName = "Dr. Arif Shah", customerType = "clinic",
            items = listOf(
                QuotationItem(3, "Surgical Scalpel Set", "SSS-002-SS", "Set (12 pcs)", 3, 1_200.00),
            ),
            status = QuotationStatus.REJECTED, note = "", createdAt = "2026-02-20",
        ),
        Quotation(
            id = 5, customerId = 5, customerName = "MediCare Supplies", customerType = "distributor",
            items = listOf(
                QuotationItem(8,  "IV Cannula 22G", "IVC-004-22G", "Box (100 pcs)", 20, 3_200.00),
                QuotationItem(10, "IV Cannula 20G", "IVC-004-20G", "Box (100 pcs)", 10, 3_600.00),
            ),
            status = QuotationStatus.ACCEPTED, note = "Monthly standing order.", createdAt = "2026-02-25",
        ),
    )
}
