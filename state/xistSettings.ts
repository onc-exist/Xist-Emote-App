import AsyncStorage from "@react-native-async-storage/async-storage";
import createContextHook from "@nkzw/create-context-hook";
import { useCallback, useEffect, useMemo, useState } from "react";

import { DEFAULT_SLOT_ASSIGNMENTS, type XistActionId } from "@/constants/xistActions";

export type XistEdge = "left" | "right" | "top" | "bottom";

export type XistOverlayPosition = {
  edge: XistEdge;
  t: number;
};

export type XistHandleSizePreset = "S" | "M" | "L";

const MAX_SLOT_COUNT = 24;

export type XistSettings = {
  isEnabled: boolean;
  slotCount: number;
  wheelSize: number;
  opacity: number;
  accentColor: string;
  enabledEdges: Record<XistEdge, boolean>;

  autoDismissEnabled: boolean;
  autoDismissMs: number;

  handleSize: XistHandleSizePreset;

  overlayPosition: XistOverlayPosition | null;

  slotAssignments: XistActionId[];
};

const STORAGE_KEY = "xist_settings_v1";

const DEFAULT_SETTINGS: XistSettings = {
  isEnabled: true,
  slotCount: 10,
  wheelSize: 148,
  opacity: 0.72,
  accentColor: "#2A6BFF",
  enabledEdges: {
    left: true,
    right: true,
    top: true,
    bottom: true,
  },

  autoDismissEnabled: true,
  autoDismissMs: 3500,

  handleSize: "M",

  overlayPosition: null,

  slotAssignments: DEFAULT_SLOT_ASSIGNMENTS,
};

function clampNumber(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
}

function normalizeSettings(input: Partial<XistSettings> | null | undefined): XistSettings {
  const merged: XistSettings = {
    ...DEFAULT_SETTINGS,
    ...(input ?? {}),
    enabledEdges: {
      ...DEFAULT_SETTINGS.enabledEdges,
      ...((input?.enabledEdges as Partial<Record<XistEdge, boolean>>) ?? {}),
    },
    slotAssignments: Array.isArray(input?.slotAssignments)
      ? (input?.slotAssignments as XistActionId[])
      : DEFAULT_SLOT_ASSIGNMENTS,
  };

  merged.slotCount = clampNumber(Math.round(merged.slotCount), 4, MAX_SLOT_COUNT);
  merged.wheelSize = clampNumber(merged.wheelSize, 116, 220);
  merged.opacity = clampNumber(merged.opacity, 0.35, 0.95);

  merged.autoDismissMs = clampNumber(Math.round(merged.autoDismissMs), 800, 12000);
  merged.autoDismissEnabled = Boolean(merged.autoDismissEnabled);

  merged.handleSize = (merged.handleSize ?? "M") as XistHandleSizePreset;
  if (!(["S", "M", "L"] as const).includes(merged.handleSize)) {
    merged.handleSize = "M";
  }

  merged.overlayPosition = merged.overlayPosition
    ? {
        edge: merged.overlayPosition.edge,
        t: clampNumber(merged.overlayPosition.t, 0, 1),
      }
    : null;

  const incomingAssignments = Array.isArray(merged.slotAssignments)
    ? (merged.slotAssignments as XistActionId[])
    : [];

  const seed = DEFAULT_SLOT_ASSIGNMENTS.length > 0 ? DEFAULT_SLOT_ASSIGNMENTS : ([] as XistActionId[]);
  const normalizedAssignments: XistActionId[] = [];

  for (let i = 0; i < MAX_SLOT_COUNT; i++) {
    const candidate = incomingAssignments[i];
    if (typeof candidate === "string") {
      normalizedAssignments[i] = candidate as XistActionId;
    } else {
      normalizedAssignments[i] = (seed[i % seed.length] ?? "boost") as XistActionId;
    }
  }

  merged.slotAssignments = normalizedAssignments;

  return merged;
}

export const [XistSettingsProvider, useXistSettings] = createContextHook(() => {
  const [settings, setSettings] = useState<XistSettings>(DEFAULT_SETTINGS);
  const [isHydrating, setIsHydrating] = useState<boolean>(true);

  useEffect(() => {
    let cancelled = false;

    const run = async () => {
      try {
        const raw = await AsyncStorage.getItem(STORAGE_KEY);
        const parsed = raw ? (JSON.parse(raw) as Partial<XistSettings>) : null;
        const next = normalizeSettings(parsed);
        console.log("[XistSettings] hydrate", { hasStored: !!raw, next });
        if (!cancelled) setSettings(next);
      } catch (e) {
        console.log("[XistSettings] hydrate error", e);
      } finally {
        if (!cancelled) setIsHydrating(false);
      }
    };

    run();

    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (isHydrating) return;

    let cancelled = false;

    const run = async () => {
      try {
        const payload = JSON.stringify(settings);
        await AsyncStorage.setItem(STORAGE_KEY, payload);
        if (!cancelled) console.log("[XistSettings] persisted");
      } catch (e) {
        console.log("[XistSettings] persist error", e);
      }
    };

    run();

    return () => {
      cancelled = true;
    };
  }, [isHydrating, settings]);

  const setIsEnabled = useCallback((value: boolean) => {
    setSettings((prev) => ({ ...prev, isEnabled: value }));
  }, []);

  const setSlotCount = useCallback((count: number) => {
    setSettings((prev) => ({
      ...prev,
      slotCount: clampNumber(Math.round(count), 4, MAX_SLOT_COUNT),
    }));
  }, []);

  const setWheelSize = useCallback((size: number) => {
    setSettings((prev) => ({ ...prev, wheelSize: clampNumber(size, 116, 220) }));
  }, []);

  const setSlotAssignments = useCallback((next: XistActionId[]) => {
    setSettings((prev) => ({ ...prev, slotAssignments: next }));
  }, []);

  const resetOverlayPosition = useCallback(() => {
    setSettings((prev) => ({ ...prev, overlayPosition: null }));
  }, []);

  const setAutoDismissEnabled = useCallback((value: boolean) => {
    setSettings((prev) => ({ ...prev, autoDismissEnabled: value }));
  }, []);

  const setAutoDismissMs = useCallback((ms: number) => {
    setSettings((prev) => ({ ...prev, autoDismissMs: clampNumber(Math.round(ms), 800, 12000) }));
  }, []);

  const setHandleSize = useCallback((value: XistHandleSizePreset) => {
    setSettings((prev) => ({ ...prev, handleSize: value }));
  }, []);

  const setOverlayPosition = useCallback((value: XistOverlayPosition | null) => {
    setSettings((prev) => ({ ...prev, overlayPosition: value }));
  }, []);

  const setSlotAssignment = useCallback((slotIndex: number, actionId: XistActionId) => {
    setSettings((prev) => {
      const next = prev.slotAssignments.slice();
      if (slotIndex < 0 || slotIndex >= next.length) return prev;
      next[slotIndex] = actionId;
      return { ...prev, slotAssignments: next };
    });
  }, []);

  const resetSlots = useCallback(() => {
    const next: XistActionId[] = [];
    for (let i = 0; i < MAX_SLOT_COUNT; i++) {
      next.push((DEFAULT_SLOT_ASSIGNMENTS[i % DEFAULT_SLOT_ASSIGNMENTS.length] ?? "boost") as XistActionId);
    }
    setSettings((prev) => ({ ...prev, slotAssignments: next }));
  }, []);

  const setOpacity = useCallback((opacity: number) => {
    setSettings((prev) => ({ ...prev, opacity: clampNumber(opacity, 0.35, 0.95) }));
  }, []);

  const setAccentColor = useCallback((accentColor: string) => {
    setSettings((prev) => ({ ...prev, accentColor }));
  }, []);

  const setEdgeEnabled = useCallback((edge: XistEdge, enabled: boolean) => {
    setSettings((prev) => ({
      ...prev,
      enabledEdges: { ...prev.enabledEdges, [edge]: enabled },
    }));
  }, []);

  const isAnyEdgeEnabled = useMemo(() => {
    return Object.values(settings.enabledEdges).some(Boolean);
  }, [settings.enabledEdges]);

  const normalizedSettings = useMemo(() => {
    if (!isAnyEdgeEnabled) {
      return {
        ...settings,
        enabledEdges: { ...DEFAULT_SETTINGS.enabledEdges },
      };
    }
    return settings;
  }, [isAnyEdgeEnabled, settings]);

  return {
    ...normalizedSettings,
    maxSlotCount: MAX_SLOT_COUNT,
    isHydrating,
    setIsEnabled,
    setSlotCount,
    setWheelSize,
    setOpacity,
    setAccentColor,
    setEdgeEnabled,
    setAutoDismissEnabled,
    setAutoDismissMs,
    setHandleSize,
    setOverlayPosition,
    setSlotAssignment,
    setSlotAssignments,
    resetSlots,
    resetOverlayPosition,
  };
});
