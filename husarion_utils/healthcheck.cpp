#include "fstream"
#include "nav_msgs/msg/odometry.hpp"
#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/imu.hpp"
#include "sensor_msgs/msg/joint_state.hpp"
#include <cstdlib>

using namespace std::chrono;
using namespace std::chrono_literals;

#define HEALTHCHECK_PERIOD 500ms
#define MSG_VALID_TIME 2s

class HealthCheckNode : public rclcpp::Node {
public:
  HealthCheckNode()
      : Node("healthcheck_rosbot"), last_ekf_msg_(steady_clock::duration(0)),
        last_imu_msg_(steady_clock::duration(0)),
        last_motors_msg_(steady_clock::duration(0)) {

    sub_ekf_ = create_subscription<nav_msgs::msg::Odometry>(
        "odometry/filtered", rclcpp::SystemDefaultsQoS().keep_last(1),
        std::bind(&HealthCheckNode::ekfCallback, this, std::placeholders::_1));

    sub_imu_ = create_subscription<sensor_msgs::msg::Imu>(
        "/_imu/data_raw", rclcpp::SystemDefaultsQoS().keep_last(1),
        std::bind(&HealthCheckNode::imuCallback, this, std::placeholders::_1));

    sub_motors_ = create_subscription<sensor_msgs::msg::JointState>(
        "/_motors_response", rclcpp::SystemDefaultsQoS().keep_last(1),
        std::bind(&HealthCheckNode::motorsCallback, this,
                  std::placeholders::_1));

    healthcheck_timer_ = create_wall_timer(
        HEALTHCHECK_PERIOD, std::bind(&HealthCheckNode::healthyCheck, this));
  }

private:
  steady_clock::time_point last_ekf_msg_;
  steady_clock::time_point last_imu_msg_;
  steady_clock::time_point last_motors_msg_;

  rclcpp::Subscription<nav_msgs::msg::Odometry>::SharedPtr sub_ekf_;
  rclcpp::Subscription<sensor_msgs::msg::Imu>::SharedPtr sub_imu_;
  rclcpp::Subscription<sensor_msgs::msg::JointState>::SharedPtr sub_motors_;
  rclcpp::TimerBase::SharedPtr healthcheck_timer_;

  bool isMsgValid(steady_clock::time_point current_time,
                  steady_clock::time_point last_msg) {
    duration<double> elapsed_time = current_time - last_msg;
    return elapsed_time < MSG_VALID_TIME;
  }

  void healthyCheck() {
    auto current_time = steady_clock::now();

    bool is_ekf = isMsgValid(current_time, last_ekf_msg_);
    bool is_imu = isMsgValid(current_time, last_imu_msg_);
    bool is_motors = isMsgValid(current_time, last_motors_msg_);

    if (is_ekf && is_imu && is_motors) {
      writeHealthStatus("healthy");
    } else {
      writeHealthStatus("unhealthy");
    }
  }

  void writeHealthStatus(const std::string &status) {
    std::ofstream healthFile("/var/tmp/health_status.txt");
    healthFile << status;
  }

  void ekfCallback(const nav_msgs::msg::Odometry::SharedPtr msg) {
    RCLCPP_DEBUG_ONCE(get_logger(), "EKF msg arrived");
    last_ekf_msg_ = steady_clock::now();
  }

  void imuCallback(const sensor_msgs::msg::Imu::SharedPtr msg) {
    RCLCPP_DEBUG_ONCE(get_logger(), "IMU msg arrived");
    last_imu_msg_ = steady_clock::now();
  }

  void motorsCallback(const sensor_msgs::msg::JointState::SharedPtr msg) {
    RCLCPP_DEBUG_ONCE(get_logger(), "Motors msg arrived");
    last_motors_msg_ = steady_clock::now();
  }
};

int main(int argc, char *argv[]) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<HealthCheckNode>());
  rclcpp::shutdown();
  return 0;
}
