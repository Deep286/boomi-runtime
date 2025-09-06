import http from 'k6/http';
import { check, sleep } from 'k6';

// K6 Performance Test Configuration
export const options = {
  stages: [
    { duration: '5m', target: 50 },   // Ramp up to 50 users over 5 minutes
    { duration: '10m', target: 100 }, // Stay at 100 users for 10 minutes
    { duration: '5m', target: 50 },   // Ramp down to 50 users over 5 minutes
  ],
  maxDuration: '20m',
  thresholds: {
    http_req_duration: ['p(95)<2000'], // 95% of requests should be below 2s
    http_req_failed: ['rate<0.05'],    // Error rate should be less than 5%
  },
};

// Base URL for the application (should be set via environment variable)
const BASE_URL = __ENV.BASE_URL || 'http://localhost:9090';

// Request headers
const HEADERS = {
  'Accept': '*/*',
  'User-Agent': 'k6-performance-test',
};

// Main test function
export default function () {
  // Health check endpoint
  const response = http.get(`${BASE_URL}/_admin/readiness`, {
    headers: HEADERS,
    timeout: '10s',
  });

  // Validate response
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time is acceptable': (r) => r.timings.duration < 2000,
    'response has content': (r) => r.body && r.body.length > 0,
  });

  // Log errors for debugging
  if (response.status !== 200) {
    console.log(`❌ Request failed: Status ${response.status}`);
  }

  // Pause between iterations
  sleep(1);
}

// Setup function
export function setup() {
  console.log('🚀 Starting performance test');
  console.log(`📊 Target URL: ${BASE_URL}`);
}

// Teardown function
export function teardown(data) {
  console.log('🏁 Performance test completed');
}
