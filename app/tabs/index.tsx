import React, { useCallback } from "react";
import { Stack } from "expo-router";
import {
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from "react-native";

import { useXistSettings } from "@/state/xistSettings";

export default function HomeScreen() {
  const { setIsEnabled, isEnabled } = useXistSettings();

  const toggleEnabled = useCallback(() => {
    console.log("[Xist] toggle enabled", { from: isEnabled, to: !isEnabled });
    setIsEnabled(!isEnabled);
  }, [isEnabled, setIsEnabled]);

  return (
    <View style={styles.screen} testID="xist-home">
      <Stack.Screen options={{ title: "Xist" }} />

      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.hero}>
          <Text style={styles.kicker}>Smart Floating Wheel</Text>
          <Text style={styles.title}>One arrow.{"\n"}All your quick actions.</Text>
          <Text style={styles.subtitle}>
            Drag the edge arrow. Tap to open the radial wheel. Tap outside to
            dismiss.
          </Text>

          <View style={styles.row}>
            <Pressable
              testID="xist-toggle-enabled"
              onPress={toggleEnabled}
              style={({ pressed }) => [
                styles.primaryButton,
                pressed && styles.primaryButtonPressed,
              ]}
            >
              <Text style={styles.primaryButtonText}>
                {isEnabled ? "Disable overlay" : "Enable overlay"}
              </Text>
            </Pressable>

            <View style={styles.pill}>
              <Text style={styles.pillText}>
                {Platform.OS === "web"
                  ? "Web preview: simulates overlay" 
                  : "Native: in-app overlay"}
              </Text>
            </View>
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Try this</Text>
          <Text style={styles.cardText}>• Drag the arrow to any edge</Text>
          <Text style={styles.cardText}>• Release to snap</Text>
          <Text style={styles.cardText}>• Tap to open the wheel</Text>
          <Text style={styles.cardText}>• Tap outside wheel to pass-through</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Next: customize slots</Text>
          <Text style={styles.cardText}>
            Open Settings to change slot count, opacity and accent.
          </Text>
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: "#070A12",
  },
  content: {
    padding: 16,
    paddingBottom: 28,
    gap: 14,
  },
  hero: {
    borderRadius: 24,
    padding: 18,
    backgroundColor: "rgba(255,255,255,0.06)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.10)",
  },
  kicker: {
    color: "rgba(255,255,255,0.72)",
    fontSize: 13,
    fontWeight: "600" as const,
    letterSpacing: 0.4,
    marginBottom: 10,
  },
  title: {
    color: "#FFFFFF",
    fontSize: 32,
    lineHeight: 34,
    fontWeight: "800" as const,
    marginBottom: 10,
  },
  subtitle: {
    color: "rgba(255,255,255,0.70)",
    fontSize: 15,
    lineHeight: 20,
  },
  row: {
    marginTop: 14,
    flexDirection: "row",
    gap: 10,
    alignItems: "center",
    flexWrap: "wrap",
  },
  primaryButton: {
    backgroundColor: "#2A6BFF",
    paddingHorizontal: 14,
    paddingVertical: 11,
    borderRadius: 14,
  },
  primaryButtonPressed: {
    transform: [{ scale: 0.98 }],
    opacity: 0.92,
  },
  primaryButtonText: {
    color: "#FFFFFF",
    fontSize: 14,
    fontWeight: "700" as const,
    letterSpacing: 0.2,
  },
  pill: {
    paddingHorizontal: 12,
    paddingVertical: 9,
    borderRadius: 999,
    backgroundColor: "rgba(255,255,255,0.07)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.10)",
  },
  pillText: {
    color: "rgba(255,255,255,0.70)",
    fontSize: 12,
    fontWeight: "600" as const,
  },
  card: {
    borderRadius: 18,
    padding: 16,
    backgroundColor: "rgba(255,255,255,0.05)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.09)",
  },
  cardTitle: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "700" as const,
    marginBottom: 8,
  },
  cardText: {
    color: "rgba(255,255,255,0.70)",
    fontSize: 13,
    lineHeight: 18,
  },
});
