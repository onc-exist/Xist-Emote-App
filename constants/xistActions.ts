import type { ComponentType } from "react";
import {
  Aperture,
  Camera,
  Crown,
  Flame,
  Hand,
  Heart,
  Laugh,
  Mic,
  Moon,
  Music,
  Phone,
  Play,
  Smile,
  Sparkles,
  Star,
  Sun,
  Sword,
  ThumbsUp,
  Volume2,
  Zap,
} from "lucide-react-native";

export type XistActionId =
  | "boost"
  | "mic"
  | "emote"
  | "snap"
  | "sound"
  | "magic"
  | "clap"
  | "like"
  | "laugh"
  | "heart"
  | "music"
  | "torch"
  | "focus"
  | "shield"
  | "crown"
  | "sun"
  | "moon"
  | "call";

export type XistAction = {
  id: XistActionId;
  label: string;
  icon: ComponentType<{ color?: string; size?: number }>;
};

export const XIST_ACTIONS: readonly XistAction[] = [
  { id: "boost", label: "Boost", icon: Zap },
  { id: "mic", label: "Mic", icon: Mic },
  { id: "emote", label: "Emote", icon: Smile },
  { id: "snap", label: "Snap", icon: Camera },
  { id: "sound", label: "Sound", icon: Volume2 },
  { id: "magic", label: "Magic", icon: Sparkles },
  { id: "clap", label: "Clap", icon: Hand },
  { id: "like", label: "Like", icon: ThumbsUp },
  { id: "laugh", label: "Laugh", icon: Laugh },
  { id: "heart", label: "Heart", icon: Heart },
  { id: "music", label: "Music", icon: Music },
  { id: "torch", label: "Torch", icon: Flame },
  { id: "focus", label: "Focus", icon: Aperture },
  { id: "shield", label: "Shield", icon: Sword },
  { id: "crown", label: "Crown", icon: Crown },
  { id: "sun", label: "Sun", icon: Sun },
  { id: "moon", label: "Moon", icon: Moon },
  { id: "call", label: "Call", icon: Phone },
] as const;

export const DEFAULT_SLOT_ASSIGNMENTS: XistActionId[] = [
  "boost",
  "mic",
  "emote",
  "snap",
  "sound",
  "magic",
  "like",
  "heart",
];

export function getActionById(id: XistActionId): XistAction {
  const found = XIST_ACTIONS.find((a) => a.id === id);
  return found ?? XIST_ACTIONS[0];
}

export function getActionIds(): XistActionId[] {
  return XIST_ACTIONS.map((a) => a.id);
}
