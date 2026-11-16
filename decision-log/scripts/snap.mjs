// Screenshot or PDF of a URL for a decision-log preview.
// Usage: node snap.mjs <url> <out.png|out.pdf> [--pdf] [--full] [--width 1440] [--height 900] [--wait "<text>"]
// Run from a directory whose node_modules has @playwright/test (resolved from the current directory).
import { createRequire } from "node:module"

const args = process.argv.slice(2)
const [url, out] = args
if (!url || !out) {
	console.error("usage: node snap.mjs <url> <out> [--pdf] [--full] [--width N] [--height N] [--wait text]")
	process.exit(1)
}
const opt = (name, fallback) => {
	const i = args.indexOf(name)
	return i === -1 ? fallback : args[i + 1]
}
const { chromium } = createRequire(`${process.cwd()}/`)("@playwright/test")

const browser = await chromium.launch()
const page = await browser.newPage({ viewport: { width: Number(opt("--width", 1440)), height: Number(opt("--height", 900)) } })
await page.goto(url, { waitUntil: "networkidle" })
const wait = opt("--wait")
if (wait) await page.getByText(wait).first().waitFor({ timeout: 90000 })
await page.waitForTimeout(800) // fonts and late charts
if (args.includes("--pdf")) {
	await page.emulateMedia({ media: "print" })
	await page.pdf({ path: out, preferCSSPageSize: true }) // backgrounds as the page asks (print-color-adjust)
} else {
	await page.screenshot({ path: out, fullPage: args.includes("--full") })
}
await browser.close()
console.log(out)
