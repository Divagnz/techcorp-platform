export class EnterpriseUtils {
  static validateLicense(licenseKey: string): boolean {
    return licenseKey.length > 10 && licenseKey.startsWith('ENT-');
  }

  static getFeatureFlags(): string[] {
    return ['advanced-analytics', 'custom-branding', 'sso', 'audit-logs'];
  }

  static formatEnterpriseDate(date: Date): string {
    return date.toISOString().split('T')[0];
  }

  static getTierLevel(tier: string): number {
    const tiers = { basic: 1, standard: 2, premium: 3, enterprise: 4 };
    return tiers[tier.toLowerCase() as keyof typeof tiers] || 0;
  }
}
