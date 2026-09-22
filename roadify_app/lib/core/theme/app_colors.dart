import 'package:flutter/material.dart';

/// Paleta de cores semântica e institucional do Roadify Mobile.
///
/// Baseada nos protótipos oficiais, prioriza alto contraste para uso
/// em ambientes iluminados (Modo Claro) e suporte a Modo Escuro veicular.
abstract final class AppColors {
  // --- Cores Institucionais Principais ---
  /// Verde Floresta / Petróleo Escuro principal da marca
  static const Color primary = Color(0xFF134E3F);
  /// Variação mais clara para estados de foco e gradientes
  static const Color primaryLight = Color(0xFF1B5E45);
  /// Variação mais escura para contrastes profundos
  static const Color primaryDark = Color(0xFF0C3329);

  // --- Acentos e Cores de Destaque ---
  /// Verde Limão Vibrante (utilizado na bolha do nível e badges de sensor ativo)
  static const Color limeAccent = Color(0xFFA3E635);
  /// Variação escura do verde limão para texto em fundo claro
  static const Color limeAccentDark = Color(0xFF65A30D);

  /// Ciano / Teal técnico secundário
  static const Color secondary = Color(0xFF0E8388);
  static const Color secondaryLight = Color(0xFF2DD4BF);

  // --- Alertas e Status ---
  /// Vermelho Coral para paradas de gravação, erros e anomalias críticas
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);

  /// Âmbar para avisos e trechos de média qualidade
  static const Color warning = Color(0xFFF59E0B);

  /// Verde esmeralda para sucesso e sincronizado
  static const Color success = Color(0xFF10B981);

  // --- Superfícies e Fundos (Modo Claro - Prioritário para Luz do Sol) ---
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // --- Superfícies e Fundos (Modo Escuro / Noturno) ---
  static const Color backgroundDark = Color(0xFF09120F);
  static const Color surfaceDark = Color(0xFF111E1A);
  static const Color cardDark = Color(0xFF162520);
  static const Color borderDark = Color(0xFF233630);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // --- Escala de Qualidade do Pavimento (5 Níveis do Roadify) ---
  /// Nível 1: Excelente
  static const Color qualityExcelente = Color(0xFF10B981);
  /// Nível 2: Boa
  static const Color qualityBoa = Color(0xFF34D399);
  /// Nível 3: Média / Regular
  static const Color qualityMedia = Color(0xFFF59E0B);
  /// Nível 4: Ruim
  static const Color qualityRuim = Color(0xFFF97316);
  /// Nível 5: Muito Ruim / Crítica (Sinaliza necessidade de perfilômetro)
  static const Color qualityMuitoRuim = Color(0xFFEF4444);
}
