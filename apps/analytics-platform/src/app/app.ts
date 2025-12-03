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
}
