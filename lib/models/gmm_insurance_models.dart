import 'package:flutter/material.dart';

/// Perfil preconfigurado de una aseguradora mexicana de Gastos Médicos Mayores
class GmmInsurerProfile {
  final String id;
  final String name;
  final String policyExample;
  final double defaultDeductible;
  final List<double> commonDeductibles;
  final double defaultCoinsurance;
  final List<double> commonCoinsurances;
  final double defaultStopLoss;
  final bool hasStopLossByDefault;
  final bool hasZeroDeductibleAccident;
  final double outOfNetworkCoinsurancePenalty;
  final String notes;
  final Color primaryColor;

  const GmmInsurerProfile({
    required this.id,
    required this.name,
    required this.policyExample,
    required this.defaultDeductible,
    required this.commonDeductibles,
    required this.defaultCoinsurance,
    required this.commonCoinsurances,
    required this.defaultStopLoss,
    this.hasStopLossByDefault = true,
    this.hasZeroDeductibleAccident = true,
    this.outOfNetworkCoinsurancePenalty = 10.0,
    required this.notes,
    required this.primaryColor,
  });

  /// Lista oficial de aseguradoras líderes en el mercado de GMM en México
  static const List<GmmInsurerProfile> mexicanInsurers = [
    GmmInsurerProfile(
      id: 'gnp',
      name: 'GNP Seguros',
      policyExample: 'Línea Azul Premier / Flexible',
      defaultDeductible: 26000.0,
      commonDeductibles: [16000, 26000, 36000, 52000, 75000],
      defaultCoinsurance: 10.0,
      commonCoinsurances: [10.0, 15.0, 20.0],
      defaultStopLoss: 55000.0,
      hasStopLossByDefault: true,
      hasZeroDeductibleAccident: true,
      outOfNetworkCoinsurancePenalty: 10.0,
      notes: 'Líder en México. Beneficio de Cero Deducible por Accidente común si el gasto supera el monto de reclamación.',
      primaryColor: Color(0xFFF97316), // Naranja característico de GNP
    ),
    GmmInsurerProfile(
      id: 'axa',
      name: 'AXA Seguros',
      policyExample: 'Flex Plus / Plan Integral',
      defaultDeductible: 24000.0,
      commonDeductibles: [15000, 24000, 35000, 48000, 70000],
      defaultCoinsurance: 10.0,
      commonCoinsurances: [10.0, 15.0, 20.0],
      defaultStopLoss: 50000.0,
      hasStopLossByDefault: true,
      hasZeroDeductibleAccident: true,
      outOfNetworkCoinsurancePenalty: 10.0,
      notes: 'Esquema modular Flex Plus con beneficios de Círculo Médico y reducción en hospitales preferentes.',
      primaryColor: Color(0xFFE11D48), // Rojo AXA
    ),
    GmmInsurerProfile(
      id: 'metlife',
      name: 'MetLife México',
      policyExample: 'MedicalLife / Práctico 360',
      defaultDeductible: 25000.0,
      commonDeductibles: [15000, 25000, 40000, 60000, 80000],
      defaultCoinsurance: 10.0,
      commonCoinsurances: [10.0, 15.0, 20.0],
      defaultStopLoss: 60000.0,
      hasStopLossByDefault: true,
      hasZeroDeductibleAccident: true,
      outOfNetworkCoinsurancePenalty: 10.0,
      notes: 'Alta presencia corporativa. Cero Deducible por Accidente con monto mínimo procedente.',
      primaryColor: Color(0xFF0284C7), // Azul MetLife
    ),
    GmmInsurerProfile(
      id: 'smnyl',
      name: 'Seguros Monterrey NYL',
      policyExample: 'Alfa Medical / Flex',
      defaultDeductible: 28000.0,
      commonDeductibles: [18000, 28000, 42000, 56000, 85000],
      defaultCoinsurance: 10.0,
      commonCoinsurances: [10.0, 15.0, 20.0],
      defaultStopLoss: 52000.0,
      hasStopLossByDefault: true,
      hasZeroDeductibleAccident: true,
      outOfNetworkCoinsurancePenalty: 10.0,
      notes: 'Especialista en Vida y GMM. Redes hospitalarias por niveles (A, AA, AAA) y deducibles anuales.',
      primaryColor: Color(0xFF2563EB), // Azul Royal Monterrey
    ),
    GmmInsurerProfile(
      id: 'mapfre',
      name: 'Mapfre México',
      policyExample: 'Protección Médica a tu Medida',
      defaultDeductible: 22000.0,
      commonDeductibles: [14000, 22000, 32000, 48000, 65000],
      defaultCoinsurance: 10.0,
      commonCoinsurances: [10.0, 15.0, 20.0],
      defaultStopLoss: 50000.0,
      hasStopLossByDefault: true,
      hasZeroDeductibleAccident: true,
      outOfNetworkCoinsurancePenalty: 10.0,
      notes: 'Planes flexibles en pesos y UMA, con opciones de tope de coaseguro configurable.',
      primaryColor: Color(0xFFDC2626), // Rojo Mapfre
    ),
    GmmInsurerProfile(
      id: 'inbursa',
      name: 'Seguros Inbursa',
      policyExample: 'Inbursa Medic / Integral',
      defaultDeductible: 20000.0,
      commonDeductibles: [12000, 20000, 30000, 45000, 60000],
      defaultCoinsurance: 10.0,
      commonCoinsurances: [10.0, 15.0, 20.0],
      defaultStopLoss: 45000.0,
      hasStopLossByDefault: true,
      hasZeroDeductibleAccident: true,
      outOfNetworkCoinsurancePenalty: 10.0,
      notes: 'Pólizas accesibles con amplia red de centros médicos del Grupo Sanborns y hospitales privados.',
      primaryColor: Color(0xFF0D9488), // Verde azulado / Teal
    ),
    GmmInsurerProfile(
      id: 'banorte',
      name: 'Seguros Banorte',
      policyExample: 'GMM Tu Médico en Casa / Protección Total',
      defaultDeductible: 25000.0,
      commonDeductibles: [15000, 25000, 35000, 50000, 75000],
      defaultCoinsurance: 10.0,
      commonCoinsurances: [10.0, 15.0, 20.0],
      defaultStopLoss: 50000.0,
      hasStopLossByDefault: true,
      hasZeroDeductibleAccident: true,
      outOfNetworkCoinsurancePenalty: 10.0,
      notes: 'Banca-seguros con atención directa y cobertura nacional.',
      primaryColor: Color(0xFFBE123C), // Borgoña Banorte
    ),
    GmmInsurerProfile(
      id: 'custom',
      name: 'Personalizada / Otra',
      policyExample: 'Cualquier Aseguradora en México',
      defaultDeductible: 25000.0,
      commonDeductibles: [10000, 20000, 30000, 50000, 100000],
      defaultCoinsurance: 10.0,
      commonCoinsurances: [5.0, 10.0, 15.0, 20.0, 25.0],
      defaultStopLoss: 50000.0,
      hasStopLossByDefault: true,
      hasZeroDeductibleAccident: true,
      outOfNetworkCoinsurancePenalty: 10.0,
      notes: 'Configura manualmente el deducible, coaseguro, tope y beneficios según las condiciones generales de tu carátula de póliza.',
      primaryColor: Color(0xFF8B5CF6), // Púrpura personalizado
    ),
  ];
}

/// Parámetros de entrada para la simulación de siniestro en GMM
class GmmCalculationInput {
  final double totalClaim; // Gasto total bruto (hospital, honorarios, medicinas)
  final double nonCoveredExpenses; // Insumos no cubiertos, exceso de tabulador, etc.
  final double contractedDeductible; // Deducible contratado
  final double contractedCoinsurance; // % Coaseguro contratado (ej: 10%)
  final bool hasStopLoss; // ¿Tiene tope de coaseguro?
  final double stopLossAmount; // Monto máximo de coaseguro en MXN
  final bool isAccident; // ¿Es consecuencia de un accidente?
  final bool hasZeroDeductibleBenefit; // ¿Tiene cláusula de cero deducible por accidente?
  final bool isOutOfNetwork; // ¿Se atendió en hospital/médico fuera de la red convenida?
  final double outOfNetworkPenalty; // % adicional de coaseguro por fuera de red

  const GmmCalculationInput({
    required this.totalClaim,
    this.nonCoveredExpenses = 0.0,
    required this.contractedDeductible,
    required this.contractedCoinsurance,
    this.hasStopLoss = true,
    this.stopLossAmount = 50000.0,
    this.isAccident = false,
    this.hasZeroDeductibleBenefit = true,
    this.isOutOfNetwork = false,
    this.outOfNetworkPenalty = 10.0,
  });
}

/// Resultado integral del cálculo de siniestro de GMM
class GmmCalculationResult {
  final bool isClaimCovered; // ¿Superó el deducible y procede el pago?
  final String? nonCoverageReason; // Razón si no procede
  final double totalClaim; // Gasto total presentado
  final double nonCoveredExpenses; // No cubiertos
  final double eligibleExpenses; // Gasto procedente (Total - No cubiertos)
  final double appliedDeductible; // Deducible efectivamente aplicado
  final double coinsuranceBase; // Base sobre la que se aplica coaseguro
  final double appliedCoinsuranceRate; // Tasa % efectiva de coaseguro (con penalización si aplica)
  final double calculatedCoinsurance; // Coaseguro matemático preliminar
  final double effectiveCoinsurance; // Coaseguro tras aplicar tope
  final bool isStopLossReached; // ¿Se alcanzó el tope de coaseguro?
  final double stopLossSavings; // Cuánto se ahorró el asegurado gracias al tope
  final double totalInsuredPayment; // Desembolso total del asegurado
  final double totalInsurerPayment; // Monto a cargo de la aseguradora
  final double insuredPercentage; // % del total que absorbe el asegurado
  final double insurerPercentage; // % del total que cubre el seguro

  const GmmCalculationResult({
    required this.isClaimCovered,
    this.nonCoverageReason,
    required this.totalClaim,
    required this.nonCoveredExpenses,
    required this.eligibleExpenses,
    required this.appliedDeductible,
    required this.coinsuranceBase,
    required this.appliedCoinsuranceRate,
    required this.calculatedCoinsurance,
    required this.effectiveCoinsurance,
    required this.isStopLossReached,
    required this.stopLossSavings,
    required this.totalInsuredPayment,
    required this.totalInsurerPayment,
    required this.insuredPercentage,
    required this.insurerPercentage,
  });
}
