#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(scriptDirectory, "../..");
const contentRoots = [
  "01通用规则",
  "02当前项目",
  "03知识库",
  "04历史项目",
  "05经验总结",
  "06治理文档",
  "examples",
  "探索项目",
];
const skippedDirectories = new Set([
  ".git",
  ".obsidian",
  ".workbuddy",
  ".zcode",
  "node_modules",
  "_temp",
]);

function walk(directory, files = []) {
  if (!fs.existsSync(directory)) return files;
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    if (entry.isDirectory() && skippedDirectories.has(entry.name)) continue;
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) walk(absolutePath, files);
    else if (entry.isFile() && entry.name.endsWith(".md")) files.push(absolutePath);
  }
  return files;
}

const markdownFiles = contentRoots.flatMap((directory) => walk(path.join(root, directory)));
for (const rootFile of ["README.md", "00主页.md", "AGENTS.md"]) {
  const absolutePath = path.join(root, rootFile);
  if (fs.existsSync(absolutePath)) markdownFiles.push(absolutePath);
}
const markdownByStem = new Map();
for (const file of markdownFiles) {
  const stem = path.basename(file, ".md");
  const matches = markdownByStem.get(stem) ?? [];
  matches.push(file);
  markdownByStem.set(stem, matches);
}

function cleanTarget(rawTarget, wikiLink = false) {
  let target = rawTarget.trim();
  if (wikiLink) {
    target = target.replace(/\\\|/g, "|").split("|", 1)[0].trim();
  }
  if (target.startsWith("<") && target.endsWith(">")) {
    target = target.slice(1, -1);
  } else if (!wikiLink) {
    target = target.replace(/\s+["'][^"']*["']\s*$/, "").trim();
  }
  target = target.split("#", 1)[0].split("?", 1)[0].trim();
  try {
    target = decodeURIComponent(target);
  } catch {
    // Keep the original target when it is not URL encoded correctly.
  }
  return target;
}

function candidatePaths(sourceFile, target, wikiLink) {
  if (!target) return [];
  const relativeSource = path.relative(root, sourceFile).split(path.sep);
  const scopedRoot = ["02当前项目", "03知识库", "04历史项目"].includes(relativeSource[0])
    ? path.join(root, relativeSource[0], relativeSource[1])
    : null;
  const relativeCandidates = [
    path.resolve(path.dirname(sourceFile), target),
    path.resolve(root, target.replace(/^\//, "")),
  ];
  if (scopedRoot) relativeCandidates.push(path.resolve(scopedRoot, target));
  const candidates = new Set(relativeCandidates);
  for (const candidate of relativeCandidates) {
    if (!candidate.toLowerCase().endsWith(".md")) candidates.add(`${candidate}.md`);
    candidates.add(path.join(candidate, "_index.md"));
  }
  if (wikiLink && !target.includes("/")) {
    for (const candidate of markdownByStem.get(target) ?? []) candidates.add(candidate);
  }
  return [...candidates];
}

function isExternalOrTemplate(target) {
  return (
    /^(?:https?:|mailto:|tel:|data:|javascript:|obsidian:|app:)/i.test(target) ||
    target.startsWith("#") ||
    /[{}*]/.test(target) ||
    /(?:^|\/)xxx(?:[_.#/]|$)/i.test(target)
  );
}

const brokenLinks = [];
let checkedLinks = 0;

for (const file of markdownFiles) {
  const original = fs.readFileSync(file, "utf8");
  const content = original
    .replace(/```[\s\S]*?```/g, "")
    .replace(/`[^`\n]+`/g, "");
  const patterns = [
    { type: "markdown", regex: /!?\[[^\]]*\]\(([^)]+)\)/g, wikiLink: false },
    { type: "wiki", regex: /!?(?:\[\[)([^\]]+)(?:\]\])/g, wikiLink: true },
  ];

  for (const { type, regex, wikiLink } of patterns) {
    for (const match of content.matchAll(regex)) {
      const rawTarget = match[1];
      if (isExternalOrTemplate(rawTarget.trim())) continue;
      const target = cleanTarget(rawTarget, wikiLink);
      if (!target) continue;
      checkedLinks += 1;
      const resolved = candidatePaths(file, target, wikiLink).some((candidate) =>
        fs.existsSync(candidate),
      );
      if (resolved) continue;
      const line = original.slice(0, match.index).split("\n").length;
      brokenLinks.push({
        file: path.relative(root, file),
        line,
        type,
        target: rawTarget.trim(),
      });
    }
  }
}

console.log(`Markdown files: ${markdownFiles.length}`);
console.log(`Local links checked: ${checkedLinks}`);
console.log(`Broken links: ${brokenLinks.length}`);
for (const broken of brokenLinks) {
  console.log(`${broken.file}:${broken.line}\t${broken.type}\t${broken.target}`);
}

process.exitCode = brokenLinks.length === 0 ? 0 : 1;
