# ============================================
# NORTHSTAR ANALYSIS - FULLY FIXED CODE
# ============================================

# Create folder for charts
dir.create("northstar_charts", showWarnings = FALSE)

# ============================================
# READ YOUR CSV FILES
# ============================================

# Main analysis files
zone_data <- read.csv("C:/Users/ASUS/Desktop/ANC database/RUN CSV/Zone Performance Analysis .csv")
complaint_data <- read.csv("C:/Users/ASUS/Desktop/ANC database/RUN CSV/Customer Complaint Analysis .csv")
driver_data <- read.csv("C:/Users/ASUS/Desktop/ANC database/RUN CSV/Driver Performance by Experience Level .csv")
vehicle_data <- read.csv("C:/Users/ASUS/Desktop/ANC database/RUN CSV/Vehicle Battery Health vs Delivery Problems .csv")
hub_data <- read.csv("C:/Users/ASUS/Desktop/ANC database/RUN CSV/Hub Performance Analysis .csv")

# ============================================
# CHECK IF FILES LOADED
# ============================================

cat("✅ Zone data:", nrow(zone_data), "rows\n")
cat("✅ Complaint data:", nrow(complaint_data), "rows\n")
cat("✅ Driver data:", nrow(driver_data), "rows\n")
cat("✅ Vehicle data:", nrow(vehicle_data), "rows\n")
cat("✅ Hub data:", nrow(hub_data), "rows\n")

# ============================================
# VIEW WHAT'S IN YOUR VEHICLE DATA
# ============================================

cat("\n🔍 VEHICLE DATA CONTENTS:\n")
print(vehicle_data)

# ============================================
# CHART 1: Zone Failure Rates
# ============================================

png("northstar_charts/1_zone_failure_rates.png", width = 800, height = 500)
zones <- zone_data[,1]
failure_rates <- as.numeric(as.character(zone_data[,5]))
barplot(failure_rates, names.arg = zones, col = "coral", 
        main = "Delivery Failure Rate by Zone", 
        xlab = "Zone", ylab = "Failure Rate (%)",
        ylim = c(0, max(failure_rates, na.rm = TRUE) + 10))
text(1:length(failure_rates), failure_rates + 3, paste0(failure_rates, "%"), cex = 1.2)
dev.off()
cat("✅ Chart 1 saved\n")

# ============================================
# CHART 2: Complaint Types
# ============================================

png("northstar_charts/2_complaint_types.png", width = 800, height = 500)
complaint_types <- complaint_data[,1]
complaint_counts <- as.numeric(as.character(complaint_data[,2]))
barplot(complaint_counts, names.arg = complaint_types, col = "steelblue", 
        main = "Customer Complaints by Type", 
        xlab = "Complaint Type", ylab = "Number of Complaints",
        las = 2, ylim = c(0, max(complaint_counts, na.rm = TRUE) + 20))
text(1:length(complaint_counts), complaint_counts + 10, complaint_counts, cex = 1.2)
dev.off()
cat("✅ Chart 2 saved\n")

# ============================================
# CHART 3: Driver Performance
# ============================================

png("northstar_charts/3_driver_experience.png", width = 700, height = 500)
driver_exp <- driver_data[,1]
on_time_rates <- as.numeric(as.character(driver_data[,3]))
barplot(on_time_rates, names.arg = driver_exp, col = c("orange", "lightblue", "darkgreen"), 
        main = "On-Time Performance by Driver Experience", 
        xlab = "Experience Level", ylab = "On-Time Rate (%)",
        ylim = c(0, 100))
text(1:length(on_time_rates), on_time_rates + 3, paste0(on_time_rates, "%"), cex = 1.2)
dev.off()
cat("✅ Chart 3 saved\n")

# ============================================
# CHART 4: Vehicle Battery (FIXED VERSION)
# ============================================

# First, check if vehicle data exists and has values
if(nrow(vehicle_data) > 0 && ncol(vehicle_data) >= 3) {
  
  # Convert to numeric safely
  battery_status <- as.character(vehicle_data[,1])
  vehicle_counts <- as.numeric(as.character(vehicle_data[,2]))
  problem_rates <- as.numeric(as.character(vehicle_data[,3]))
  
  # Remove any NA values
  valid_rows <- !is.na(vehicle_counts) & !is.na(problem_rates)
  
  if(sum(valid_rows) > 0) {
    battery_status <- battery_status[valid_rows]
    vehicle_counts <- vehicle_counts[valid_rows]
    problem_rates <- problem_rates[valid_rows]
    
    png("northstar_charts/4_vehicle_battery.png", width = 800, height = 500)
    
    bar_data <- rbind(vehicle_counts, problem_rates)
    max_val <- max(c(vehicle_counts, problem_rates), na.rm = TRUE)
    
    barplot(bar_data, beside = TRUE, names.arg = battery_status,
            col = c("steelblue", "coral"),
            main = "Vehicle Battery Health Impact",
            xlab = "Battery Status", ylab = "Value",
            ylim = c(0, max_val + 10))
    legend("topright", legend = c("Number of Vehicles", "Problem Rate (%)"), 
           fill = c("steelblue", "coral"))
    dev.off()
    cat("✅ Chart 4 saved\n")
  } else {
    cat("⚠️ Chart 4 skipped: No valid numeric data in vehicle file\n")
    # Create a blank placeholder
    png("northstar_charts/4_vehicle_battery.png", width = 800, height = 500)
    plot(1, type = "n", main = "Vehicle Battery Data Not Available", xlab = "", ylab = "")
    text(1, 1, "Check CSV file format", cex = 1.2)
    dev.off()
    cat("✅ Placeholder chart 4 saved\n")
  }
} else {
  cat("⚠️ Chart 4 skipped: Vehicle data file has issues\n")
}

# ============================================
# CHART 5: Hub Performance
# ============================================

png("northstar_charts/5_hub_performance.png", width = 1000, height = 500)
hub_names <- hub_data[,1]
hub_rates <- as.numeric(as.character(hub_data[,3]))
colors <- ifelse(hub_rates == min(hub_rates, na.rm = TRUE), "red", "lightgreen")
barplot(hub_rates, names.arg = hub_names, col = colors,
        main = "Hub Performance Ranking",
        xlab = "Hub Name", ylab = "On-Time Rate (%)",
        ylim = c(0, 100), las = 2)
text(1:length(hub_rates), hub_rates + 3, paste0(hub_rates, "%"), cex = 0.9)
dev.off()
cat("✅ Chart 5 saved\n")

# ============================================
# DONE!
# ============================================

cat("\n")
cat("========================================\n")
cat("✅ ANALYSIS COMPLETE!\n")
cat("========================================\n")
cat("\n📁 Charts saved to: northstar_charts folder\n")

# Show where the folder is
cat("\n📍 Folder location:", getwd(), "/northstar_charts\n")

cat("\n📊 Charts created:\n")
cat("   1. Zone Failure Rates\n")
cat("   2. Complaint Types\n")
cat("   3. Driver Experience Impact\n")
if(file.exists("northstar_charts/4_vehicle_battery.png")) {
  cat("   4. Vehicle Battery Impact\n")
}
cat("   5. Hub Performance Ranking\n")