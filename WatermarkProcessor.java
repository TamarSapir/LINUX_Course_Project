import java.awt.*;
import java.awt.font.FontRenderContext;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;

public class WatermarkProcessor {
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Usage: java WatermarkProcessor <output_directory>");
            return;
        }
        String outputDir = args[0];

     
        String studentName1 = System.getenv("STUDENT_NAME_1");
        String studentId1 = System.getenv("STUDENT_ID_1");
        String studentName2 = System.getenv("STUDENT_NAME_2");
        String studentId2 = System.getenv("STUDENT_ID_2");

        if (studentName1 == null || studentId1 == null || studentName2 == null || studentId2 == null) {
            System.out.println("Error: Missing student information.");
            return;
        }

        System.out.println("Processing images for: " + studentName1 + " (" + studentId1 + ") and " + studentName2 + " (" + studentId2 + ")");

        File outputFolder = new File(outputDir);
        if (!outputFolder.exists()) {
            outputFolder.mkdirs();
        }

        File inputFolder = new File("/app/images");

        if (!inputFolder.exists() || !inputFolder.isDirectory()) {
            System.out.println("Error: Input directory does not exist!");
            return;
        }

        File[] imageFiles = inputFolder.listFiles();
        if (imageFiles == null || imageFiles.length == 0) {
            System.out.println("No images found.");
            return;
        }

        for (File imageFile : imageFiles) {
            if (imageFile.isFile() && (imageFile.getName().toLowerCase().endsWith(".png") || imageFile.getName().toLowerCase().endsWith(".jpg") || imageFile.getName().toLowerCase().endsWith(".jpeg"))) {
                try {
                    BufferedImage image = ImageIO.read(imageFile);
                    Graphics2D g2d = (Graphics2D) image.getGraphics();

               
                    Font font = new Font("Calibri", Font.BOLD, 50); 
                    g2d.setFont(font);
                    g2d.setColor(new Color(0, 0, 255, 150)); 

                  
                    FontRenderContext frc = g2d.getFontRenderContext();
                    String line1 = studentName1 + " - " + studentId1;
                    String line2 = studentName2 + " - " + studentId2;
                    Rectangle2D textBounds1 = font.getStringBounds(line1, frc);
                    Rectangle2D textBounds2 = font.getStringBounds(line2, frc);

                    int textWidth1 = (int) textBounds1.getWidth();
                    int textHeight = (int) textBounds1.getHeight(); 
                    int textWidth2 = (int) textBounds2.getWidth();

   
                    int x1 = (image.getWidth() - textWidth1) / 2;
                    int x2 = (image.getWidth() - textWidth2) / 2;

         
                    int centerY = image.getHeight() / 2;
                    int y1 = centerY - textHeight / 2; 
                    int y2 = centerY + textHeight; 

              
                    g2d.drawString(line1, x1, y1);
                    g2d.drawString(line2, x2, y2);
                    g2d.dispose();

                    
                    File outputImage = new File(outputFolder, imageFile.getName());
                    ImageIO.write(image, "png", outputImage);
                    System.out.println("Processed: " + outputImage.getAbsolutePath());

                } catch (IOException e) {
                    System.err.println("Error processing file: " + imageFile.getName());
                }
            }
        }
    }
}
