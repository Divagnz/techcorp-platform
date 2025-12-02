export class AnalyticsUtils {
  static calculateMetrics(data: number[]): { mean: number; sum: number } {
    const sum = data.reduce((acc, val) => acc + val, 0);
    const mean = sum / data.length;
    return { mean, sum };
  }

  static formatPercentage(value: number): string {
    return `${(value * 100).toFixed(2)}%`;
  }

  static getTimestamp(): string {
    return new Date().toISOString();
  }
}
