import React from 'react';

// Iframe을 렌더링하는 재사용 가능한 컴포넌트입니다.
const KibanaDashboard = ({ src, title }) => {
  return (
    <div style={{ border: '1px solid #eee', borderRadius: '8px', padding: '16px', marginBottom: '24px', background: '#fff' }}>
      <h3 style={{ marginTop: 0 }}>{title}</h3>
      <iframe
        src={src}
        title={title}
        width="100%"
        height="600px"
        style={{ border: 'none' }}
        loading="lazy"
      ></iframe>
    </div>
  );
};

export default KibanaDashboard;