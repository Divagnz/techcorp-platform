import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  standalone: false,
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  protected title = 'customer-portal';
  protected version = '0.1.0';

  getAppInfo() {
    return {
      title: this.title,
      version: this.version,
      timestamp: new Date().toISOString()
    };
  }
}
