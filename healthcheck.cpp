#include "fstream"
#include "nav_msgs/msg/odometry.hpp"
#include "rclcpp/rclcpp.hpp"
#include <cstdlib>

using namespace std::chrono_literals;

#define LOOP_PERIOD 500ms
#define MSG_VALID_TIME 2s

std::chrono::steady_clock::time_point last_msg_time;

void write_health_status(const std::string &status) {
  std::ofstream healthFile("/var/tmp/health_status.txt");
  healthFile << status;
}

void msg_callback(const nav_msgs::msg::Odometry::SharedPtr msg) {
  last_msg_time = std::chrono::steady_clock::now();
}

void healthy_check() {
  std::chrono::steady_clock::time_point current_time =
      std::chrono::steady_clock::now();
  std::chrono::duration<double> elapsed_time = current_time - last_msg_time;
  bool is_msg_valid = elapsed_time.count() < MSG_VALID_TIME.count();

  if (is_msg_valid) {
    write_health_status("healthy");
  } else {
    write_health_status("unhealthy");
  }
}

int main(int argc, char *argv[]) {
  rclcpp::init(argc, argv);

  std::string topic = "odometry/filtered";
  if (const char *ns = std::getenv("ROS_NAMESPACE")) {
    topic = std::string(ns) + "/" + topic;
  }

  auto node = rclcpp::Node::make_shared("healthcheck_node");
  auto sub = node->create_subscription<nav_msgs::msg::Odometry>(
      topic, rclcpp::SensorDataQoS().keep_last(1), msg_callback);

  while (rclcpp::ok()) {
    rclcpp::spin_some(node);
    healthy_check();
    std::this_thread::sleep_for(LOOP_PERIOD);
  }

  return 0;
}
