// template
import { Tabs } from "expo-router";
import { Home, Settings } from "lucide-react-native";
import React from "react";
import { StyleSheet, View } from "react-native";

import Colors from "@/constants/colors";
import { FloatingWheelOverlay } from "@/components/FloatingWheelOverlay";

export default function TabLayout() {
  return (
    <View style={styles.root}>
      <Tabs
        screenOptions={{
          tabBarActiveTintColor: Colors.light.tint,
          headerShown: true,
        }}
      >
        <Tabs.Screen
          name="index"
          options={{
            title: "Xist",
            tabBarIcon: ({ color, size }) => (
              <Home color={color} size={size} />
            ),
          }}
        />
        <Tabs.Screen
          name="settings"
          options={{
            title: "Settings",
            tabBarIcon: ({ color, size }) => (
              <Settings color={color} size={size} />
            ),
          }}
        />
      </Tabs>

      <FloatingWheelOverlay />
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
  },
});
