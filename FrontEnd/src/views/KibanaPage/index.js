// BookingRestauantList 화면 불러옴
import React from "react";
import KibanaDashboard from "./kibanaDashboard";

export default function KibanaPage(){
    // 각 대시보드의 Iframe URL을 변수로 저장합니다.
  const kibana_url_kmsg = process.env.REACT_APP_KIBANA_URL_KMSG;
  const kibana_url_service = process.env.REACT_APP_KIBANA_URL_SERVICE;
  const kibana_url_auth = process.env.REACT_APP_KIBANA_URL_AUTH;

  const securityDashboardUrl = `${kibana_url_auth}`;
  const infraDashboardUrl = `${kibana_url_kmsg}`;
  const apiDashboardUrl = `${kibana_url_service}`;

  return (
    <div style={{ padding: '20px' }}>
      <h1 style={{ marginBottom: '30px', color: 'white' }}>통합 로그 모니터링 대시보드</h1>
      
      <KibanaDashboard
        src={securityDashboardUrl}
        title="[Security] 보안 감사 대시보드"
      />
      
      <KibanaDashboard
        src={infraDashboardUrl}
        title="[System] 인프라 상태 대시보드"
      />
      
      <KibanaDashboard
        src={apiDashboardUrl}
        title="[API] 서비스 현황 대시보드"
      />
    </div>
  );
}
