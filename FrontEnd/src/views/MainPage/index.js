import React, { useEffect, useRef, useState } from "react";
import './index.css'; 

function MainPage() {
    const bannerRef = useRef(null);
    const [visible, setVisible] = useState(false);

    useEffect(() => {
        const observer = new IntersectionObserver(
            (entries) => {
                entries.forEach((entry) => setVisible(entry.isIntersecting));
            },
            { threshold: 0.5 }
        );
        if (bannerRef.current) observer.observe(bannerRef.current);
        return () => observer.disconnect();
    }, []);

    return (
        <div className="MainContainer" ref={bannerRef}>
            <div className="Layout">
                <div className="Main-logo">
                    <img
                        src="/assets/mainpagelogo.png"
                        alt="I'm SOLOg – 데이터센터 지킴이"
                    />
                </div>

                <div className="Right">
                    <div className="BackBox" />
                    <div className="FrontBox">
                        <p>
                            SOLOG는 Log 데이터를 활용해 <br />문제 해결(SOLVE)을 보조하는 <br />
                            통합 시각화, 알림 서비스입니다.
                        </p>
                        <p>
                            Kibana를 통한 로그 정보 모니터링, <br />
                            Grafana를 통한 매트릭 모니터링 <br /> 기능을 제공합니다.
                        </p>
                        <p>
                            사전 정의된 규칙에 따라 발생된 알림을 모아 확인하고 <br />
                            AI의 조언과 함께 문제 해결의 첫걸음을 시작하세요.
                        </p>
                    </div>
                </div>
            </div>
            <div className="Bottom">
                <div className="Logos">
                    <img src="/assets/logo_moel.png" alt="고용노동부" />
                    <img src="/assets/logo_autoever.png" alt="현대오토에버" />
                    <img src="/assets/logo_rapa.png" alt="RAPA" />
                </div>
                <div className="TeamText">© Team j4s | 문의: autoeversolog@gmail.com</div>
            </div>
        </div>
    );
}

export default MainPage;

