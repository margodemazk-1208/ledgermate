import 'package:flutter/material.dart';

class WalletIconItem {
  const WalletIconItem({
    required this.key,
    required this.label,
    required this.icon,
  });

  final String key;
  final String label;
  final IconData icon;
}

const List<WalletIconItem> supportedWalletIcons = [
  WalletIconItem(
    key: 'account_balance_wallet',
    label: 'Dompet / Tunai',
    icon: Icons.account_balance_wallet,
  ),
  WalletIconItem(
    key: 'account_balance',
    label: 'Bank / Rekening',
    icon: Icons.account_balance,
  ),
  WalletIconItem(
    key: 'credit_card',
    label: 'Kartu Debit / Kredit',
    icon: Icons.credit_card,
  ),
  WalletIconItem(
    key: 'phone_android',
    label: 'E-Wallet',
    icon: Icons.phone_android,
  ),
  WalletIconItem(key: 'savings', label: 'Tabungan', icon: Icons.savings),
  WalletIconItem(key: 'payments', label: 'Kas / Uang', icon: Icons.payments),
  WalletIconItem(
    key: 'attach_money',
    label: 'Investasi / Valas',
    icon: Icons.attach_money,
  ),
  WalletIconItem(
    key: 'storefront',
    label: 'Bisnis / Toko',
    icon: Icons.storefront,
  ),
];

IconData getWalletIcon(String? key) {
  for (final item in supportedWalletIcons) {
    if (item.key == key) return item.icon;
  }
  return Icons.account_balance_wallet;
}
