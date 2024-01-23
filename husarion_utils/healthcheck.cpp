#include "fstream"
#include "nav_msgs/msg/odometry.hpp"
#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/imu.hpp"
#include <cstdlib>

using namespace std::chrono;
using namespace std::chrono_literals;

#define HEALTHCHECK_PERIOD 500ms
#define MSG_VALID_TIME 2s

class HealthCheckNode : public rclcpp::Node {
public:
  HealthCheckNode()
      : Node("healthcheck_rosbot"), last_controller_msg_(steady_clock::now()),
        last_ekf_msg_(steady_clock::now()), last_imu_msg_(steady_clock::now()) {

    sub_controller_ = create_subscription<nav_msgs::msg::Odometry>(
        "rosbot_base_controller/odom",
        rclcpp::SystemDefaultsQoS().keep_last(1).transient_local(),
        std::bind(&HealthCheckNode::controllerCallback, this,
                  std::placeholders::_1));

    sub_ekf_ = create_subscription<nav_msgs::msg::Odometry>(
        "odometry/filtered", rclcpp::SystemDefaultsQoS().keep_last(1),
        std::bind(&HealthCheckNode::ekfCallback, this, std::placeholders::_1));

    sub_imu_ = create_subscription<sensor_msgs::msg::Imu>(
        "imu_broadcaster/imu",
        rclcpp::SystemDefaultsQoS().keep_last(1).transient_local(),
        std::bind(&HealthCheckNode::imuCallback, this, std::placeholders::_1));

    healthcheck_timer_ = create_wall_timer(
        HEALTHCHECK_PERIOD, std::bind(&HealthCheckNode::healthyCheck, this));
  }

private:
  steady_clock::time_point last_controller_msg_;
  steady_clock::time_point last_ekf_msg_;
  steady_clock::time_point last_imu_msg_;

  rclcpp::Subscription<nav_msgs::msg::Odometry>::SharedPtr sub_controller_;
  rclcpp::Subscription<nav_msgs::msg::Odometry>::SharedPtr sub_ekf_;
  rclcpp::Subscription<sensor_msgs::msg::Imu>::SharedPtr sub_imu_;
  rclcpp::TimerBase::SharedPtr healthcheck_timer_;

  bool isMsgValid(steady_clock::time_point current_time,
                  steady_clock::time_point last_msg) {
    duration<double> elapsed_time = current_time - last_controller_msg_;
    return elapsed_time < MSG_VALID_TIME;
  }

  void healthyCheck() {
    auto current_time = steady_clock::now();

    bool is_controller = isMsgValid(current_time, last_ekf_msg_);
    bool is_ekf = isMsgValid(current_time, last_ekf_msg_);
    bool is_imu = isMsgValid(current_time, last_imu_msg_);

    if (is_controller && is_ekf && is_imu) {
      writeHealthStatus("healthy");
    } else {
      writeHealthStatus("unhealthy");
    }
  }

  void writeHealthStatus(const std::string &status) {
    std::ofstream healthFile("/var/tmp/health_status.txt");
    healthFile << status;
  }

  void controllerCallback(const nav_msgs::msg::Odometry::SharedPtr msg) {
    RCLCPP_DEBUG_ONCE(get_logger(), "Map msg arrived");
    last_controller_msg_ = steady_clock::now();
  }

  void ekfCallback(const nav_msgs::msg::Odometry::SharedPtr msg) {
    RCLCPP_DEBUG_ONCE(get_logger(), "Map msg arrived");
    last_controller_msg_ = steady_clock::now();
  }

  void imuCallback(const sensor_msgs::msg::Imu::SharedPtr msg) {
    RCLCPP_DEBUG_ONCE(get_logger(), "Map msg arrived");
    last_controller_msg_ = steady_clock::now();
  }
};

int main(int argc, char *argv[]) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<HealthCheckNode>());
  rclcpp::shutdown();
  return 0;
}
