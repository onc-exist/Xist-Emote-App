import { BlurView } from "expo-blur";
import * as Haptics from "expo-haptics";
import React, { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  Animated,
  PanResponder,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  useWindowDimensions,
  View,
} from "react-native";
import {
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  ChevronUp,
} from "lucide-react-native";

import { getActionById, type XistActionId } from "@/constants/xistActions";
import { useXistSettings, type XistEdge } from "@/state/xistSettings";

type AnchorPoint = { x: number; y: number };

const XIST_EDGES = ["left", "right", "top", "bottom"] as const;

function getEnabledEdges(enabled: Record<XistEdge, boolean>): XistEdge[] {
  return XIST_EDGES.filter((edge) => enabled[edge]);
}

type WheelAction = {
  id: XistActionId;
  label: string;
  icon: React.ComponentType<{ color?: string; size?: number }>;
};

const PEEK = 12;
const SLOT_SIZE = 52;
const SLOT_GAP = 12;
const CAROUSEL_HEIGHT = 66;

function clampNumber(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
}

function nearestEdge(
  point: AnchorPoint,
  size: { width: number; height: number },
  enabled: Record<XistEdge, boolean>,
): XistEdge {
  const candidates = XIST_EDGES.map((edge) => {
    const value =
      edge === "left"
        ? point.x
        : edge === "right"
          ? size.width - point.x
          : edge === "top"
            ? point.y
            : size.height - point.y;

    return { edge, value };
  });

  const enabledEdges = getEnabledEdges(enabled);

  const distances = candidates.filter((d) => enabledEdges.includes(d.edge));

  if (distances.length === 0) return "right";

  distances.sort((a, b) => a.value - b.value);
  return distances[0].edge;
}

function snapToEdge(
  point: AnchorPoint,
  edge: XistEdge,
  size: { width: number; height: number },
  handleSize: { width: number; height: number },
): AnchorPoint {
  const pad = 8;

  if (edge === "left") {
    return {
      x: -PEEK,
      y: clampNumber(point.y, pad, size.height - pad - handleSize.height),
    };
  }

  if (edge === "right") {
    return {
      x: size.width - handleSize.width + PEEK,
      y: clampNumber(point.y, pad, size.height - pad - handleSize.height),
    };
  }

  if (edge === "top") {
    return {
      x: clampNumber(point.x, pad, size.width - pad - handleSize.width),
      y: -PEEK,
    };
  }

  return {
    x: clampNumber(point.x, pad, size.width - pad - handleSize.width),
    y: size.height - handleSize.height + PEEK,
  };
}

function ArrowIcon({ edge, color }: { edge: XistEdge; color: string }) {
  const size = 18;
  if (edge === "left") return <ChevronRight color={color} size={size} />;
  if (edge === "right") return <ChevronLeft color={color} size={size} />;
  if (edge === "top") return <ChevronDown color={color} size={size} />;
  return <ChevronUp color={color} size={size} />;
}

function pluralizeSlot(count: number) {
  return count === 1 ? "slot" : "slots";
}

export function FloatingWheelOverlay() {
  const {
    isEnabled,
    isHydrating,
    slotCount,
    wheelSize,
    opacity,
    accentColor,
    enabledEdges,
    autoDismissEnabled,
    autoDismissMs,
    handleSize,
    overlayPosition,
    setOverlayPosition,
    slotAssignments,
  } = useXistSettings();

  const { width, height } = useWindowDimensions();
  const screenSize = useMemo(() => ({ width, height }), [width, height]);

  const handleSizePx = useMemo(() => {
    const thickness = handleSize === "S" ? 40 : handleSize === "L" ? 48 : 44;
    const length = handleSize === "S" ? 56 : handleSize === "L" ? 70 : 62;
    return {
      width: thickness,
      height: length,
    };
  }, [handleSize]);

  const [edge, setEdge] = useState<XistEdge>("right");
  const [isExpanded, setIsExpanded] = useState<boolean>(false);

  const position = useRef<AnchorPoint>({ x: 0, y: 0 });
  const pan = useRef<Animated.ValueXY>(new Animated.ValueXY({ x: 0, y: 0 }))
    .current;

  const bloom = useRef<Animated.Value>(new Animated.Value(0)).current;
  const dragWasMoved = useRef<boolean>(false);

  const applySnap = useCallback(
    (nextEdge: XistEdge, point: AnchorPoint, animated: boolean, persist: boolean) => {
      const snapped = snapToEdge(point, nextEdge, screenSize, handleSizePx);
      position.current = snapped;
      setEdge(nextEdge);

      if (persist) {
        const size = nextEdge === "left" || nextEdge === "right" ? screenSize.height : screenSize.width;
        const handleLen = nextEdge === "left" || nextEdge === "right" ? handleSizePx.height : handleSizePx.width;
        const denom = Math.max(1, size - handleLen);
        const tRaw = nextEdge === "left" || nextEdge === "right" ? snapped.y / denom : snapped.x / denom;
        const t = clampNumber(tRaw, 0, 1);
        console.log("[XistOverlay] persist position", { nextEdge, t });
        setOverlayPosition({ edge: nextEdge, t });
      }

      if (animated) {
        Animated.spring(pan, {
          toValue: snapped,
          useNativeDriver: false,
          speed: 22,
          bounciness: 7,
        }).start();
      } else {
        pan.setValue(snapped);
      }

      console.log("[XistOverlay] snapped", { nextEdge, snapped });
    },
    [handleSizePx, pan, screenSize, setOverlayPosition],
  );

  useEffect(() => {
    if (isHydrating) return;

    if (!isEnabled) {
      setIsExpanded(false);
      Animated.timing(bloom, {
        toValue: 0,
        duration: 140,
        useNativeDriver: true,
      }).start();
      return;
    }

    const enabledEdgeList = getEnabledEdges(enabledEdges);
    const fallbackEdge: XistEdge = enabledEdgeList.includes("right")
      ? "right"
      : enabledEdgeList[0] ?? "right";

    const initialEdge: XistEdge =
      overlayPosition?.edge && enabledEdgeList.includes(overlayPosition.edge)
        ? overlayPosition.edge
        : fallbackEdge;

    const size = initialEdge === "left" || initialEdge === "right" ? screenSize.height : screenSize.width;
    const handleLen = initialEdge === "left" || initialEdge === "right" ? handleSizePx.height : handleSizePx.width;
    const denom = Math.max(1, size - handleLen);
    const t = clampNumber(overlayPosition?.t ?? 0.42, 0, 1);

    const start =
      initialEdge === "left" || initialEdge === "right"
        ? {
            x: initialEdge === "left" ? -PEEK : screenSize.width - handleSizePx.width + PEEK,
            y: t * denom,
          }
        : {
            x: t * denom,
            y: initialEdge === "top" ? -PEEK : screenSize.height - handleSizePx.height + PEEK,
          };

    applySnap(initialEdge, start, false, false);
  }, [applySnap, bloom, enabledEdges, handleSizePx.height, handleSizePx.width, isEnabled, isHydrating, overlayPosition?.edge, overlayPosition?.t, screenSize.height, screenSize.width]);

  useEffect(() => {
    if (!isExpanded) {
      Animated.timing(bloom, {
        toValue: 0,
        duration: 130,
        useNativeDriver: true,
      }).start();
      return;
    }

    Animated.timing(bloom, {
      toValue: 1,
      duration: 160,
      useNativeDriver: true,
    }).start();
  }, [bloom, isExpanded]);

  const toggleExpanded = useCallback(async () => {
    if (!isEnabled) return;

    const next = !isExpanded;
    console.log("[XistOverlay] toggle", { next });
    setIsExpanded(next);

    if (next) {
      await Haptics.selectionAsync();
    }
  }, [isEnabled, isExpanded]);

  const dismiss = useCallback(() => {
    if (!isExpanded) return;
    console.log("[XistOverlay] dismiss");
    setIsExpanded(false);
  }, [isExpanded]);

  useEffect(() => {
    if (!isEnabled || isHydrating) return;

    console.log("[XistOverlay] state", {
      isEnabled,
      edge,
      isExpanded,
      slotCount,
      wheelSize,
      handleSize,
      autoDismissEnabled,
      autoDismissMs,
      overlayPosition,
    });
  }, [
    autoDismissEnabled,
    autoDismissMs,
    edge,
    handleSize,
    isEnabled,
    isExpanded,
    isHydrating,
    overlayPosition,
    slotCount,
    wheelSize,
  ]);

  useEffect(() => {
    if (!isExpanded) return;
    if (!autoDismissEnabled) return;

    const timeout = setTimeout(() => {
      console.log("[XistOverlay] timeout dismiss");
      setIsExpanded(false);
    }, autoDismissMs);

    return () => clearTimeout(timeout);
  }, [autoDismissEnabled, autoDismissMs, isExpanded]);

  const onSelect = useCallback(
    async (action: WheelAction) => {
      console.log("[XistOverlay] action", action);
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      setIsExpanded(false);
    },
    [],
  );

  const panResponder = useMemo(
    () =>
      PanResponder.create({
        onStartShouldSetPanResponder: () => true,
        onMoveShouldSetPanResponder: (_evt, gesture) => {
          const moved = Math.abs(gesture.dx) + Math.abs(gesture.dy) > 6;
          return moved;
        },
        onPanResponderGrant: () => {
          dragWasMoved.current = false;
        },
        onPanResponderMove: (_evt, gesture) => {
          if (isExpanded) return;

          dragWasMoved.current = true;

          const next: AnchorPoint = {
            x: position.current.x + gesture.dx,
            y: position.current.y + gesture.dy,
          };

          const clamped: AnchorPoint = {
            x: clampNumber(next.x, -PEEK - 20, screenSize.width - handleSizePx.width + PEEK + 20),
            y: clampNumber(next.y, -PEEK - 20, screenSize.height - handleSizePx.height + PEEK + 20),
          };

          pan.setValue(clamped);
        },
        onPanResponderRelease: (_evt, gesture) => {
          if (isExpanded) return;

          const released: AnchorPoint = {
            x: position.current.x + gesture.dx,
            y: position.current.y + gesture.dy,
          };

          const nextEdge = nearestEdge(released, screenSize, enabledEdges);
          applySnap(nextEdge, released, true, true);
        },
        onPanResponderTerminate: (_evt, gesture) => {
          if (isExpanded) return;

          const released: AnchorPoint = {
            x: position.current.x + gesture.dx,
            y: position.current.y + gesture.dy,
          };

          const nextEdge = nearestEdge(released, screenSize, enabledEdges);
          applySnap(nextEdge, released, true, true);
        },
      }),
    [applySnap, enabledEdges, handleSizePx.height, handleSizePx.width, isExpanded, pan, screenSize],
  );

  const wheelActions = useMemo((): WheelAction[] => {
    const unique = new Set<XistActionId>();
    const picked: XistActionId[] = [];

    for (const id of Array.isArray(slotAssignments) ? slotAssignments : []) {
      if (picked.length >= slotCount) break;
      if (!id) continue;
      if (unique.has(id)) continue;
      unique.add(id);
      picked.push(id);
    }

    if (picked.length < slotCount) {
      const fallbackIds: XistActionId[] = ["boost", "mic", "emote", "snap", "sound", "magic", "like", "heart"];
      for (const id of fallbackIds) {
        if (picked.length >= slotCount) break;
        if (unique.has(id)) continue;
        unique.add(id);
        picked.push(id);
      }
    }

    return picked.slice(0, slotCount).map((id) => {
      const a = getActionById(id);
      return { id: a.id, label: a.label, icon: a.icon };
    });
  }, [slotAssignments, slotCount]);

  const showCarousel = useMemo(() => slotCount > 10, [slotCount]);
  const radialCount = useMemo(
    () => (showCarousel ? Math.min(10, wheelActions.length) : wheelActions.length),
    [showCarousel, wheelActions.length],
  );

  const wheelAngleStart = useMemo(() => {
    if (edge === "left") return -60;
    if (edge === "right") return 120;
    if (edge === "top") return 30;
    return -150;
  }, [edge]);

  const wheelAngleEnd = useMemo(() => {
    if (edge === "left") return 60;
    if (edge === "right") return 240;
    if (edge === "top") return 150;
    return -30;
  }, [edge]);

  const wheelCenter = useMemo(() => {
    const p = position.current;
    const cx = p.x + handleSizePx.width / 2;
    const cy = p.y + handleSizePx.height / 2;
    return { x: cx, y: cy };
  }, [handleSizePx.height, handleSizePx.width]);

  const wheelLayerStyle = useMemo(() => {
    const scale = bloom.interpolate({ inputRange: [0, 1], outputRange: [0.88, 1] });
    const opacityAnim = bloom.interpolate({ inputRange: [0, 1], outputRange: [0, 1] });
    return {
      opacity: opacityAnim,
      transform: [{ scale }],
    };
  }, [bloom]);

  if (!isEnabled || isHydrating) return null;

  return (
    <View
      pointerEvents={isExpanded ? "auto" : "box-none"}
      style={StyleSheet.absoluteFill}
      testID="xist-overlay"
    >
      {isExpanded ? (
        <Pressable
          testID="xist-overlay-backdrop"
          onPress={dismiss}
          style={StyleSheet.absoluteFill}
        >
          <View style={styles.backdropPassThrough} />
        </Pressable>
      ) : null}

      <Animated.View
        style={[
          styles.handle,
          {
            width: handleSizePx.width,
            height: handleSizePx.height,
            opacity,
            borderColor: "rgba(255,255,255,0.16)",
            backgroundColor: "rgba(10,14,26,0.72)",
          },
          {
            transform: pan.getTranslateTransform(),
          },
        ]}
        {...panResponder.panHandlers}
      >
        <Pressable
          testID="xist-handle"
          onPress={() => {
            if (dragWasMoved.current) {
              dragWasMoved.current = false;
              return;
            }
            toggleExpanded();
          }}
          style={({ pressed }) => [
            styles.handlePress,
            pressed && styles.handlePressed,
          ]}
        >
          <ArrowIcon edge={edge} color={"rgba(255,255,255,0.88)"} />
        </Pressable>
      </Animated.View>

      {isExpanded ? (
        <Animated.View
          pointerEvents="box-none"
          style={[
            styles.wheelLayer,
            {
              left: wheelCenter.x - wheelSize,
              top: wheelCenter.y - wheelSize,
              width: wheelSize * 2,
              height: wheelSize * 2,
            },
            wheelLayerStyle,
          ]}
        >
          {Platform.OS === "web" ? (
            <View
              style={[
                styles.wheelBlurFallback,
                {
                  borderColor: "rgba(255,255,255,0.14)",
                },
              ]}
            />
          ) : (
            <BlurView
              intensity={38}
              tint="dark"
              style={[
                styles.wheelBlur,
                {
                  borderColor: "rgba(255,255,255,0.14)",
                },
              ]}
            />
          )}

          <View pointerEvents="box-none" style={StyleSheet.absoluteFill}>
            {(!showCarousel ? wheelActions : wheelActions.slice(0, radialCount)).map((action, index) => {
              const count = Math.max(1, radialCount);
              const t = count === 1 ? 0.5 : index / (count - 1);
              const angleDeg = wheelAngleStart + (wheelAngleEnd - wheelAngleStart) * t;
              const angle = (angleDeg * Math.PI) / 180;
              const r = wheelSize * 0.72;
              const cx = wheelSize + Math.cos(angle) * r;
              const cy = wheelSize + Math.sin(angle) * r;

              const within =
                cx > 10 &&
                cy > 10 &&
                cx < wheelSize * 2 - 10 &&
                cy < wheelSize * 2 - 10;

              if (!within) {
                console.log("[XistOverlay] slot out-of-bounds", {
                  action: action.id,
                  edge,
                  index,
                  cx,
                  cy,
                  wheelSize,
                });
              }

              const Icon = action.icon;

              return (
                <View
                  key={action.id}
                  style={[
                    styles.slotWrap,
                    {
                      left: cx - SLOT_SIZE / 2,
                      top: cy - SLOT_SIZE / 2,
                    },
                  ]}
                  pointerEvents="box-none"
                >
                  <Pressable
                    testID={`xist-slot-${action.id}`}
                    onPress={() => onSelect(action)}
                    style={({ pressed }) => [
                      styles.slot,
                      {
                        backgroundColor: pressed
                          ? "rgba(255,255,255,0.14)"
                          : "rgba(255,255,255,0.10)",
                        borderColor: pressed
                          ? accentColor
                          : "rgba(255,255,255,0.14)",
                        transform: pressed
                          ? [{ scale: 0.96 }]
                          : [{ scale: 1 }],
                      },
                    ]}
                  >
                    <Icon color={accentColor} size={18} />
                  </Pressable>
                </View>
              );
            })}

            {showCarousel ? (
              <View style={styles.carouselWrap} pointerEvents="auto">
                <View style={styles.carouselTitleRow}>
                  <Text style={styles.carouselTitle}>
                    {wheelActions.length} {pluralizeSlot(wheelActions.length)}
                  </Text>
                  <Text style={styles.carouselHint}>Swipe</Text>
                </View>

                <ScrollView
                  horizontal
                  showsHorizontalScrollIndicator={false}
                  decelerationRate={"fast"}
                  snapToInterval={SLOT_SIZE + SLOT_GAP}
                  snapToAlignment="center"
                  contentContainerStyle={styles.carouselContent}
                  testID="xist-wheel-carousel"
                >
                  {wheelActions.map((action) => {
                    const Icon = action.icon;
                    return (
                      <Pressable
                        key={`carousel-${action.id}`}
                        testID={`xist-carousel-slot-${action.id}`}
                        onPress={() => onSelect(action)}
                        style={({ pressed }) => [
                          styles.carouselItem,
                          {
                            borderColor: pressed ? accentColor : "rgba(255,255,255,0.14)",
                            backgroundColor: pressed
                              ? "rgba(255,255,255,0.14)"
                              : "rgba(255,255,255,0.08)",
                            transform: pressed ? [{ scale: 0.96 }] : [{ scale: 1 }],
                          },
                        ]}
                      >
                        <Icon color={accentColor} size={18} />
                      </Pressable>
                    );
                  })}
                </ScrollView>
              </View>
            ) : null}
          </View>

          <Pressable
            testID="xist-center"
            onPress={toggleExpanded}
            style={[
              styles.centerDot,
              {
                borderColor: "rgba(255,255,255,0.18)",
                backgroundColor: "rgba(10,14,26,0.78)",
              },
            ]}
          />
        </Animated.View>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  backdropPassThrough: {
    flex: 1,
    backgroundColor: "transparent",
  },
  handle: {
    position: "absolute",
    width: 44,
    height: 62,
    borderRadius: 999,
    borderWidth: 1,
    overflow: "hidden",
  },
  handlePress: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  handlePressed: {
    opacity: 0.92,
  },
  wheelLayer: {
    position: "absolute",
  },
  wheelBlur: {
    position: "absolute",
    left: 0,
    top: 0,
    right: 0,
    bottom: 0,
    borderRadius: 999,
    borderWidth: 1,
    overflow: "hidden",
  },
  wheelBlurFallback: {
    position: "absolute",
    left: 0,
    top: 0,
    right: 0,
    bottom: 0,
    borderRadius: 999,
    borderWidth: 1,
    overflow: "hidden",
    backgroundColor: "rgba(10,14,26,0.60)",
  },
  slotWrap: {
    position: "absolute",
    width: SLOT_SIZE,
    height: SLOT_SIZE,
  },
  slot: {
    flex: 1,
    borderRadius: 16,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  centerDot: {
    position: "absolute",
    left: "50%",
    top: "50%",
    width: 12,
    height: 12,
    marginLeft: -6,
    marginTop: -6,
    borderRadius: 999,
    borderWidth: 1,
  },
  carouselWrap: {
    position: "absolute",
    left: 10,
    right: 10,
    bottom: 10,
    height: CAROUSEL_HEIGHT,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: "rgba(255,255,255,0.12)",
    backgroundColor: "rgba(0,0,0,0.18)",
    overflow: "hidden",
  },
  carouselTitleRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 12,
    paddingTop: 8,
  },
  carouselTitle: {
    color: "rgba(255,255,255,0.82)",
    fontSize: 12,
    fontWeight: "800" as const,
    letterSpacing: 0.2,
  },
  carouselHint: {
    color: "rgba(255,255,255,0.48)",
    fontSize: 11,
    fontWeight: "800" as const,
  },
  carouselContent: {
    paddingHorizontal: 12,
    paddingBottom: 10,
    paddingTop: 8,
    alignItems: "center",
  },
  carouselItem: {
    width: SLOT_SIZE,
    height: SLOT_SIZE,
    borderRadius: 16,
    borderWidth: 1,
    alignItems: "center",
    justifyContent: "center",
    marginRight: SLOT_GAP,
  },
});
