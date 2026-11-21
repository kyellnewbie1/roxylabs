import type { Metadata } from 'next';
import './globals.css';
import { Shell } from '@/components/shell';
export const metadata: Metadata = { title: 'Roxy Main API', description: 'Powerful APIs, Powered by Roxy.', icons: { icon: '/roxy/favicon.jpg' } };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="id"><body><Shell>{children}</Shell></body></html>; }
