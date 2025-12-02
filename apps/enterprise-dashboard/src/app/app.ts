import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: false,
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  protected title = 'enterprise-dashboard';
  protected version = '0.1.0';
  protected modules = ['analytics', 'reporting', 'admin'];

  getDashboardConfig() {
    return {
      title: this.title,
      version: this.version,
      modules: this.modules,
      isEnterprise: true,
      timestamp: new Date().toISOString()
    };
  }
}
