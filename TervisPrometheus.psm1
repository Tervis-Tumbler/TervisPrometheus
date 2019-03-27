function Get-PrometheusNodeNames {
    Get-TervisApplicationNodeNames -Name Prometheus
}

function Start-Prometheus {
    docker run -d -p 9090:9090 --name prometheus prom/prometheus:v2.7.1
}

function Output-PrometheusConfiguration {
    $ComputerName = Get-TervisInDesignServerComputerName
    [PSCustomObject]@{
        scrape_configs = @(
            @{
                job_name = "envoy"
                metrics_path = "/stats/prometheus"
                scrape_interval = "10s"
                static_configs = @(
                    @{
                        targets = @(
                            "images2.tervis.com:9901"
                        )
                    }
                )
            },
            @{
                job_name = "wmi_exporter"
                scrape_interval = "10s"
                static_configs = @(
                    @{
                        targets = @(
                            "$($ComputerName):9182"
                        )
                    }
                )
            }
        )
    } |
    ConvertTo-Yaml |
    Out-File -FilePath prometheus.yml -Encoding ascii
}

function Copy-PrometheusConfiguration {
    docker cp prometheus.yml prometheus:/etc/prometheus/prometheus.yml
}

function Restart-Prometheus {
    docker restart prometheus
}