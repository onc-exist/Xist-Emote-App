import React, { useCallback, useMemo } from "react";
import { Stack } from "expo-router";
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Switch,
  Text,
  View,
} from "react-native";

import { getActionById, getActionIds, type XistActionId } from "@/constants/xistActions";
import { useXistSettings, type XistEdge } from "@/state/xistSettings";

const ACCENTS = [
  "#2A6BFF",
  "#00D1B2",
  "#FF2D55",
  "#FFB020",
  "#9B5CFF",
  "#34C759",
];

function SegmentedOption({
  label,
  selected,
  onPress,
  testID,
}: {
  label: string;
  selected: boolean;
  onPress: () => void;
  testID: string;
}) {
  return (
    <Pressable
      testID={testID}
      onPress={onPress}
      style={({ pressed }) => [
        styles.segment,
        selected && styles.segmentSelected,
        pressed && styles.segmentPressed,
      ]}
    >
      <Text style={[styles.segmentText, selected && styles.segmentTextSelected]}>
        {label}
      </Text>
    </Pressable>
  );
}

export default function SettingsScreen() {
  const {
    isEnabled,
    setIsEnabled,
    slotCount,
    setSlotCount,
    wheelSize,
    setWheelSize,
    opacity,
    setOpacity,
    accentColor,
    setAccentColor,
    enabledEdges,
    setEdgeEnabled,
    autoDismissEnabled,
    setAutoDismissEnabled,
    autoDismissMs,
    setAutoDismissMs,
    handleSize,
    setHandleSize,
    slotAssignments,
    setSlotAssignment,
    setSlotAssignments,
    resetSlots,
    resetOverlayPosition,
    maxSlotCount,
  } = useXistSettings();

  const slotOptions = useMemo(() => [4, 6, 8, 10, 12, 14, 16, 20, 24], []);
  const sizeOptions = useMemo(
    () => [
      { label: "S", value: 128 },
      { label: "M", value: 148 },
      { label: "L", value: 176 },
    ],
    [],
  );

  const opacityOptions = useMemo(
    () => [
      { label: "35%", value: 0.35 },
      { label: "55%", value: 0.55 },
      { label: "72%", value: 0.72 },
      { label: "90%", value: 0.9 },
    ],
    [],
  );

  const handleOptions = useMemo(
    () => [
      { label: "S", value: "S" as const },
      { label: "M", value: "M" as const },
      { label: "L", value: "L" as const },
    ],
    [],
  );

  const autoDismissOptions = useMemo(
    () => [
      { label: "0.8s", value: 800 },
      { label: "2s", value: 2000 },
      { label: "3.5s", value: 3500 },
      { label: "6s", value: 6000 },
      { label: "12s", value: 12000 },
    ],
    [],
  );

  const actionIds = useMemo(() => getActionIds(), []);

  const rotateSlot = useCallback(
    (index: number) => {
      const currentId = slotAssignments[index] as XistActionId | undefined;
      const currentIdx = currentId ? actionIds.indexOf(currentId) : -1;
      const next = actionIds[(currentIdx + 1 + actionIds.length) % actionIds.length] ?? actionIds[0];
      console.log("[XistSettings] rotate slot", { index, from: currentId, to: next });
      setSlotAssignment(index, next);
    },
    [actionIds, setSlotAssignment, slotAssignments],
  );

  const shuffleSlots = useCallback(() => {
    const picked: XistActionId[] = [];
    const pool = actionIds.slice();

    for (let i = pool.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const tmp = pool[i];
      pool[i] = pool[j] as XistActionId;
      pool[j] = tmp as XistActionId;
    }

    for (let i = 0; i < maxSlotCount; i++) {
      picked.push((pool[i % pool.length] ?? pool[0]) as XistActionId);
    }

    console.log("[XistSettings] shuffle slots", picked);
    setSlotAssignments(picked);
  }, [actionIds, maxSlotCount, setSlotAssignments]);

  const toggleEdge = useCallback(
    (edge: XistEdge) => {
      setEdgeEnabled(edge, !enabledEdges[edge]);
    },
    [enabledEdges, setEdgeEnabled],
  );

  return (
    <View style={styles.screen} testID="xist-settings">
      <Stack.Screen options={{ title: "Settings" }} />

      <ScrollView
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.card}>
          <View style={styles.cardHeaderRow}>
            <Text style={styles.cardTitle}>Overlay</Text>
            <Switch
              testID="xist-settings-enabled"
              value={isEnabled}
              onValueChange={setIsEnabled}
            />
          </View>
          <Text style={styles.cardSubtitle}>
            Turns the floating arrow on/off for this app preview.
          </Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Slot count</Text>
          <Text style={styles.cardSubtitle}>Choose how many actions show up.</Text>
          <View style={styles.segmentedRow}>
            {slotOptions.map((n) => (
              <SegmentedOption
                key={n}
                testID={`xist-settings-slots-${n}`}
                label={String(n)}
                selected={slotCount === n}
                onPress={() => setSlotCount(n)}
              />
            ))}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Wheel size</Text>
          <Text style={styles.cardSubtitle}>Affects reach + spacing.</Text>
          <View style={styles.segmentedRow}>
            {sizeOptions.map((opt) => (
              <SegmentedOption
                key={opt.label}
                testID={`xist-settings-size-${opt.label}`}
                label={opt.label}
                selected={wheelSize === opt.value}
                onPress={() => setWheelSize(opt.value)}
              />
            ))}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Opacity</Text>
          <Text style={styles.cardSubtitle}>How subtle the arrow looks.</Text>
          <View style={styles.segmentedRow}>
            {opacityOptions.map((opt) => (
              <SegmentedOption
                key={opt.label}
                testID={`xist-settings-opacity-${opt.label}`}
                label={opt.label}
                selected={Math.abs(opacity - opt.value) < 0.01}
                onPress={() => setOpacity(opt.value)}
              />
            ))}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Accent</Text>
          <Text style={styles.cardSubtitle}>Icon highlight + focus ring.</Text>
          <View style={styles.accentRow}>
            {ACCENTS.map((c) => {
              const selected = c === accentColor;
              return (
                <Pressable
                  key={c}
                  testID={`xist-settings-accent-${c}`}
                  onPress={() => setAccentColor(c)}
                  style={({ pressed }) => [
                    styles.accentDot,
                    {
                      backgroundColor: c,
                      borderColor: selected
                        ? "rgba(255,255,255,0.95)"
                        : "rgba(255,255,255,0.18)",
                      transform: pressed ? [{ scale: 0.96 }] : [{ scale: 1 }],
                    },
                  ]}
                />
              );
            })}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Allowed edges</Text>
          <Text style={styles.cardSubtitle}>
            Disable edges you never want to snap to.
          </Text>

          {(Object.keys(enabledEdges) as XistEdge[]).map((e) => (
            <Pressable
              key={e}
              testID={`xist-settings-edge-${e}`}
              onPress={() => toggleEdge(e)}
              style={({ pressed }) => [
                styles.edgeRow,
                pressed && styles.edgeRowPressed,
              ]}
            >
              <Text style={styles.edgeLabel}>{e.toUpperCase()}</Text>
              <Switch value={enabledEdges[e]} onValueChange={(v) => setEdgeEnabled(e, v)} />
            </Pressable>
          ))}
        </View>

        <View style={styles.card}>
          <View style={styles.cardHeaderRow}>
            <Text style={styles.cardTitle}>Auto-dismiss</Text>
            <Switch
              testID="xist-settings-autodismiss-enabled"
              value={autoDismissEnabled}
              onValueChange={setAutoDismissEnabled}
            />
          </View>
          <Text style={styles.cardSubtitle}>
            Collapses the wheel after a short delay.
          </Text>

          <View style={styles.segmentedRow}>
            {autoDismissOptions.map((opt) => (
              <SegmentedOption
                key={opt.label}
                testID={`xist-settings-autodismiss-${opt.value}`}
                label={opt.label}
                selected={Math.abs(autoDismissMs - opt.value) < 20}
                onPress={() => setAutoDismissMs(opt.value)}
              />
            ))}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Handle size</Text>
          <Text style={styles.cardSubtitle}>
            The arrow “hit target” size.
          </Text>
          <View style={styles.segmentedRow}>
            {handleOptions.map((opt) => (
              <SegmentedOption
                key={opt.label}
                testID={`xist-settings-handle-${opt.label}`}
                label={opt.label}
                selected={handleSize === opt.value}
                onPress={() => setHandleSize(opt.value)}
              />
            ))}
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Slot actions</Text>
          <Text style={styles.cardSubtitle}>
            Tap a slot to cycle its action. (This is a fast MVP editor — we can upgrade to a picker modal next.)
          </Text>

          <View style={styles.slotGrid}>
            {Array.from({ length: maxSlotCount }).map((_, i) => {
              const id = (slotAssignments[i] ?? "boost") as XistActionId;
              const action = getActionById(id);
              return (
                <Pressable
                  key={`${i}-${id}`}
                  testID={`xist-settings-slot-${i}`}
                  onPress={() => rotateSlot(i)}
                  style={({ pressed }) => [
                    styles.slotChip,
                    pressed && styles.slotChipPressed,
                  ]}
                >
                  <View style={styles.slotChipTopRow}>
                    <Text style={styles.slotChipIndex}>{i + 1}</Text>
                    <Text style={styles.slotChipLabel}>{action.label}</Text>
                  </View>
                  <View style={styles.slotChipBottomRow}>
                    <Text style={styles.slotChipMeta}>{id}</Text>
                    <View
                      style={[
                        styles.slotChipDot,
                        { backgroundColor: accentColor },
                      ]}
                    />
                  </View>
                </Pressable>
              );
            })}
          </View>

          <View style={styles.actionsRow}>
            <Pressable
              testID="xist-settings-slots-shuffle"
              onPress={shuffleSlots}
              style={({ pressed }) => [
                styles.secondaryButton,
                pressed && styles.secondaryButtonPressed,
              ]}
            >
              <Text style={styles.secondaryButtonText}>Shuffle</Text>
            </Pressable>

            <Pressable
              testID="xist-settings-slots-reset"
              onPress={resetSlots}
              style={({ pressed }) => [
                styles.secondaryButton,
                pressed && styles.secondaryButtonPressed,
              ]}
            >
              <Text style={styles.secondaryButtonText}>Reset</Text>
            </Pressable>
          </View>
        </View>

        <View style={styles.card}>
          <Text style={styles.cardTitle}>Position</Text>
          <Text style={styles.cardSubtitle}>
            Your last snapped edge + position is saved.
          </Text>
          <Pressable
            testID="xist-settings-position-reset"
            onPress={resetOverlayPosition}
            style={({ pressed }) => [
              styles.secondaryButton,
              pressed && styles.secondaryButtonPressed,
              { alignSelf: "flex-start" },
            ]}
          >
            <Text style={styles.secondaryButtonText}>Reset position</Text>
          </Pressable>
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
  card: {
    borderRadius: 18,
    padding: 16,
    backgroundColor: "rgba(255,255,255,0.05)",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.09)",
  },
  cardHeaderRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    gap: 12,
  },
  cardTitle: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "800" as const,
  },
  cardSubtitle: {
    color: "rgba(255,255,255,0.66)",
    fontSize: 13,
    lineHeight: 18,
    marginTop: 6,
  },
  segmentedRow: {
    flexDirection: "row",
    gap: 10,
    marginTop: 12,
    flexWrap: "wrap",
  },
  segment: {
    paddingHorizontal: 12,
    paddingVertical: 9,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.14)",
    backgroundColor: "rgba(255,255,255,0.06)",
  },
  segmentSelected: {
    borderColor: "rgba(255,255,255,0.82)",
    backgroundColor: "rgba(255,255,255,0.12)",
  },
  segmentPressed: {
    transform: [{ scale: 0.98 }],
  },
  segmentText: {
    color: "rgba(255,255,255,0.70)",
    fontSize: 13,
    fontWeight: "700" as const,
  },
  segmentTextSelected: {
    color: "#FFFFFF",
  },
  accentRow: {
    flexDirection: "row",
    gap: 12,
    marginTop: 12,
    alignItems: "center",
    flexWrap: "wrap",
  },
  accentDot: {
    width: 30,
    height: 30,
    borderRadius: 999,
    borderWidth: 2,
  },
  edgeRow: {
    marginTop: 10,
    paddingVertical: 10,
    paddingHorizontal: 10,
    borderRadius: 14,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.10)",
    backgroundColor: "rgba(255,255,255,0.04)",
  },
  edgeRowPressed: {
    transform: [{ scale: 0.99 }],
    opacity: 0.95,
  },
  edgeLabel: {
    color: "rgba(255,255,255,0.78)",
    fontSize: 12,
    fontWeight: "800" as const,
    letterSpacing: 0.8,
  },
  slotGrid: {
    marginTop: 12,
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
  },
  slotChip: {
    width: "48%",
    minWidth: 160,
    borderRadius: 16,
    padding: 12,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.10)",
    backgroundColor: "rgba(255,255,255,0.04)",
  },
  slotChipPressed: {
    transform: [{ scale: 0.99 }],
    opacity: 0.95,
  },
  slotChipTopRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  slotChipIndex: {
    width: 24,
    height: 24,
    borderRadius: 8,
    textAlign: "center",
    textAlignVertical: "center",
    overflow: "hidden",
    color: "rgba(255,255,255,0.88)",
    backgroundColor: "rgba(255,255,255,0.08)",
    fontSize: 12,
    fontWeight: "800" as const,
  },
  slotChipLabel: {
    color: "#FFFFFF",
    fontSize: 13,
    fontWeight: "800" as const,
  },
  slotChipBottomRow: {
    marginTop: 8,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  slotChipMeta: {
    color: "rgba(255,255,255,0.55)",
    fontSize: 12,
    fontWeight: "700" as const,
  },
  slotChipDot: {
    width: 10,
    height: 10,
    borderRadius: 999,
  },
  actionsRow: {
    marginTop: 12,
    flexDirection: "row",
    gap: 10,
    flexWrap: "wrap",
  },
  secondaryButton: {
    paddingHorizontal: 12,
    paddingVertical: 10,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.14)",
    backgroundColor: "rgba(255,255,255,0.06)",
  },
  secondaryButtonPressed: {
    transform: [{ scale: 0.98 }],
    opacity: 0.92,
  },
  secondaryButtonText: {
    color: "rgba(255,255,255,0.86)",
    fontSize: 13,
    fontWeight: "800" as const,
  },
});
