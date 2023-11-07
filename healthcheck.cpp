#include "rclcpp/rclcpp.hpp"
#include "nav_msgs/msg/odometry.hpp"
#include "cstdlib"

using namespace std::chrono_literals;

#define TOPIC_NAME "/odometry/filtered"
#define TIMEOUT 2s

int msg_received = EXIT_FAILURE;

void msg_callback(const nav_msgs::msg::Odometry::SharedPtr msg)
{
    std::cout << "Message received" << std::endl;
    msg_received = EXIT_SUCCESS;
    rclcpp::shutdown();
}

void timeout_callback()
{
  std::cout << "Timeout" << std::endl;
  rclcpp::shutdown();
}

int main(int argc, char* argv[])
{
  rclcpp::init(argc, argv);
  auto node = rclcpp::Node::make_shared("healthcheck_node");
  auto sub = node->create_subscription<nav_msgs::msg::Odometry>(TOPIC_NAME, rclcpp::SensorDataQoS(), msg_callback);
  auto timer = node->create_wall_timer(TIMEOUT, timeout_callback);

  rclcpp::spin(node);
  return msg_received;
}
