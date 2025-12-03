import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: false,
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  protected title = 'analytics-platform';
  protected version = '0.1.0';
  protected  Identifier = 'analytics-platform-identifier';

  getAnalyticsDashboard() {
    return {
      title: this.title,
      version: this.version,
      features: ['charts', 'reports', 'metrics'],
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Export analytics data in multiple formats
   * @param format - The desired export format (json, csv, xml)
   * @returns Formatted analytics data
   */
  exportAnalyticsData(format: 'json' | 'csv' | 'xml' = 'json') {
    const data = this.getAnalyticsDashboard();

    switch (format) {
      case 'json':
        return JSON.stringify(data, null, 2);
      case 'csv':
        return `Title,Version,Features,Timestamp\n${data.title},${data.version},"${data.features.join(';')}",${data.timestamp}`;
      case 'xml':
        return `<analytics><title>${data.title}</title><version>${data.version}</version><timestamp>${data.timestamp}</timestamp></analytics>`;
      default:
        return JSON.stringify(data);
    }
  }
}
