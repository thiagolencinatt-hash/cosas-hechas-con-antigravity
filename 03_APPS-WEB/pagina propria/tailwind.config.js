/** @type {import('tailwindcss').Config} */
export default {
  darkMode: ["class"],
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        obsidian: {
          DEFAULT: "#0A0A0A",
          pure: "#050505",
          charcoal: "#111111",
          elevated: "#181818",
          card: "#141414",
          border: "#242424",
        },
        stone: {
          alabaster: "#ECE8E1",
          bone: "#F5F5F0",
          sand: "#C5BFB6",
          muted: "#8E8E93",
          dark: "#2A2A2A",
        },
      },
      fontFamily: {
        serif: ["'Cormorant Garamond'", "'Playfair Display'", "Georgia", "serif"],
        display: ["'Cinzel'", "'Cormorant Garamond'", "serif"],
        sans: ["'Plus Jakarta Sans'", "system-ui", "-apple-system", "sans-serif"],
      },
      letterSpacing: {
        'amouage': '0.35em',
        'subtle-wide': '0.2em',
        'ultra-wide': '0.45em',
      },
      animation: {
        'marquee': 'marquee 35s linear infinite',
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.35s cubic-bezier(0.16, 1, 0.3, 1)',
        'kenburns': 'kenburns 25s ease-out infinite alternate',
      },
      keyframes: {
        marquee: {
          '0%': { transform: 'translateX(0%)' },
          '100%': { transform: 'translateX(-50%)' },
        },
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(16px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        },
        kenburns: {
          '0%': { transform: 'scale(1)' },
          '100%': { transform: 'scale(1.05)' },
        },
      },
    },
  },
  plugins: [],
};
