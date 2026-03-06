---
name: shadcn-ui
description: shadcn/ui components with Tailwind CSS. Use when building UI with shadcn components, styling with Tailwind, or creating accessible React interfaces.
---

# shadcn/ui + Tailwind CSS Skill

## Installing Components

```bash
# Initialize shadcn
npx shadcn@latest init

# Add components
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add form
npx shadcn@latest add table
npx shadcn@latest add dialog
npx shadcn@latest add dropdown-menu
npx shadcn@latest add toast
```

## Common Component Patterns

### Button Variants
```tsx
import { Button } from "@/components/ui/button"

<Button>Default</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="destructive">Delete</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>
<Button size="sm">Small</Button>
<Button size="lg">Large</Button>
<Button disabled>Disabled</Button>

// With loading state
<Button disabled={isPending}>
  {isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
  Submit
</Button>
```

### Card Layout
```tsx
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"

<Card>
  <CardHeader>
    <CardTitle>Card Title</CardTitle>
    <CardDescription>Card description here</CardDescription>
  </CardHeader>
  <CardContent>
    <p>Main content</p>
  </CardContent>
  <CardFooter className="flex justify-between">
    <Button variant="outline">Cancel</Button>
    <Button>Save</Button>
  </CardFooter>
</Card>
```

### Forms with react-hook-form + zod
```tsx
"use client"

import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"

const formSchema = z.object({
  email: z.string().email(),
  name: z.string().min(2).max(50),
})

export function ProfileForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      email: "",
      name: "",
    },
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    // Handle submission
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="email@example.com" {...field} />
              </FormControl>
              <FormDescription>Your email address</FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Submit</Button>
      </form>
    </Form>
  )
}
```

### Dialog / Modal
```tsx
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"

<Dialog>
  <DialogTrigger asChild>
    <Button>Open Dialog</Button>
  </DialogTrigger>
  <DialogContent className="sm:max-w-[425px]">
    <DialogHeader>
      <DialogTitle>Edit Profile</DialogTitle>
      <DialogDescription>
        Make changes to your profile here.
      </DialogDescription>
    </DialogHeader>
    <div className="py-4">
      {/* Form content */}
    </div>
    <DialogFooter>
      <Button type="submit">Save changes</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

### Data Table
```tsx
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"

<Table>
  <TableHeader>
    <TableRow>
      <TableHead>Name</TableHead>
      <TableHead>Status</TableHead>
      <TableHead className="text-right">Amount</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {items.map((item) => (
      <TableRow key={item.id}>
        <TableCell className="font-medium">{item.name}</TableCell>
        <TableCell>
          <Badge variant={item.status === "active" ? "default" : "secondary"}>
            {item.status}
          </Badge>
        </TableCell>
        <TableCell className="text-right">${item.amount}</TableCell>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

### Toast Notifications
```tsx
// In layout or provider
import { Toaster } from "@/components/ui/toaster"

<Toaster />

// Usage
import { useToast } from "@/hooks/use-toast"

const { toast } = useToast()

toast({
  title: "Success",
  description: "Your changes have been saved.",
})

toast({
  variant: "destructive",
  title: "Error",
  description: "Something went wrong.",
})
```

## Tailwind Patterns

### Common Layouts
```tsx
// Centered container
<div className="container mx-auto px-4 py-8">

// Flex center
<div className="flex items-center justify-center min-h-screen">

// Grid layout
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

// Sidebar layout
<div className="flex">
  <aside className="w-64 shrink-0">Sidebar</aside>
  <main className="flex-1">Content</main>
</div>
```

### Responsive Design
```tsx
// Mobile-first breakpoints
<div className="
  text-sm          // Default (mobile)
  md:text-base     // 768px+
  lg:text-lg       // 1024px+
  xl:text-xl       // 1280px+
">

// Hide/show
<div className="hidden md:block">Desktop only</div>
<div className="md:hidden">Mobile only</div>

// Responsive grid
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
```

### Common Utilities
```tsx
// Spacing
className="p-4 px-6 py-2 m-4 mx-auto my-8 space-y-4 gap-4"

// Typography
className="text-sm text-muted-foreground font-medium leading-relaxed"

// Colors (with shadcn CSS variables)
className="bg-background text-foreground"
className="bg-primary text-primary-foreground"
className="bg-muted text-muted-foreground"
className="bg-destructive text-destructive-foreground"
className="border-border"

// Effects
className="rounded-lg shadow-sm hover:shadow-md transition-shadow"
className="opacity-50 hover:opacity-100 transition-opacity"

// Truncate
className="truncate"              // Single line
className="line-clamp-2"          // 2 lines (needs plugin)
```

### Dark Mode
```tsx
// Toggle with next-themes
import { useTheme } from "next-themes"

const { theme, setTheme } = useTheme()

<Button onClick={() => setTheme(theme === "dark" ? "light" : "dark")}>
  Toggle theme
</Button>

// Conditional styles
className="bg-white dark:bg-slate-900"
```

### Animation
```tsx
// Built-in Tailwind
className="animate-spin"
className="animate-pulse"
className="animate-bounce"

// Transitions
className="transition-all duration-200 ease-in-out"
className="hover:scale-105 transition-transform"

// Custom with cn utility
import { cn } from "@/lib/utils"

<div className={cn(
  "transition-opacity duration-200",
  isVisible ? "opacity-100" : "opacity-0"
)}>
```

## cn Utility
```tsx
// lib/utils.ts
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// Usage - merges and dedupes classes
<Button className={cn(
  "w-full",
  isPrimary && "bg-blue-500",
  className
)}>
```
