import fr.dgac.ivy.*;
import java.util.*;
import java.awt.Point;

FSM currentState;
String recognizedAction = "";
String recognizedForm   = "";
String recognizedColor  = "";

int formeSelectionnee = -1;
ArrayList<Forme> formes;
Point point1;

Ivy bus, busIcar;

void setup() {
  size(800, 600);
  surface.setResizable(true);
  surface.setTitle("Palette multimodale");
  surface.setLocation(20, 20);

  formes = new ArrayList<>();
  currentState = FSM.INITIAL;

  noStroke();

  try {
      bus = new Ivy("sra5", "sra_tts_bridge is ready", null);
      busIcar = new Ivy("ICAR", "ICAR_bridge is ready", null);

      bus.start("127.255.255.255:2010");
      busIcar.start("127.255.255.255:2010");

      bus.bindMsg("^sra5 Text=(.*) Confidence=(.*)", new IvyMessageListener() {
        public void receive(IvyClient client,String[] args) {
          println("Sra5 : " + args[0]);
          parseVoiceMessage(args[0]);
        }
      });

      bus.bindMsg("^sra5 Event=Speech_Rejected", (client, args) -> {
          println("Commande vocale non reconnue.");
      });

      bus.bindMsg("^sra5 Parsed=(.*) Confidence=(.*) NP=.*", new IvyMessageListener() {
        public void receive(IvyClient client, String[] args) {
          String parsed = args[0];
          float conf = Float.parseFloat(args[1]);
          println("Vous avez dit : " + parsed + " avec un taux de confiance de " + conf);
          parseVoiceMessage(parsed);
        }
      });

      busIcar.bindMsg("^ICAR Gesture=(.*)", new IvyMessageListener() {
        public void receive(IvyClient client, String[] args) {
          println("ICAR : " + args[0]);
          parseIcarGesture(args[0]);
        }
      });

  } catch (IvyException e) {
      e.printStackTrace();
  }
}

void parseVoiceMessage(String message) {
  recognizedAction = "";
  recognizedForm   = "";
  recognizedColor  = "";

  String[] tokens = splitTokens(message, " ");

  for (String t : tokens) {
    t = t.trim();
    if (t.startsWith("action=")) {
      recognizedAction = t.substring("action=".length()).toUpperCase();
    } 
    else if (t.startsWith("form=")) {
      recognizedForm = t.substring("form=".length()).toUpperCase();
    }
    else if (t.startsWith("color=")) {
      recognizedColor = t.substring("color=".length()).toUpperCase();
    }
  }

  switch(recognizedAction) {
    case "CREATE":
      currentState = FSM.ACTION;
      break;
    case "MOVE":
      currentState = FSM.DEPLACER_FORMES_SELECTION;
      break;
    case "DELETE":
      currentState = FSM.SUPPRIMER_FORMES_SELECTION;
      break;
    default:
      currentState = FSM.WAITING;
      println("Action inconnue ou non gérée : " + recognizedAction);
  }

  println("Action = " + recognizedAction + ", Forme = " + recognizedForm + ", Couleur = " + recognizedColor);
}

void parseIcarGesture(String gesture) {
  String recognizedGesture = gesture.trim().toUpperCase();

  switch (recognizedGesture) {
    case "CIRCLE":
    case "TRIANGLE":
    case "RECTANGLE":
    case "DIAMOND":
      recognizedForm = recognizedGesture;
      recognizedAction = "CREATE";
      if (recognizedColor == null 
          || recognizedColor.isEmpty() 
          || recognizedColor.equals("UNDEFINED")) {
        recognizedColor = "DARK";
      }
      currentState = FSM.ACTION;
      break;

    default:
      println("Geste ICAR non reconnu : " + recognizedGesture);
      currentState = FSM.WAITING;
      break;
  }
}

void draw() {
  background(255);
  for (Forme f : formes) {
    f.update();
  }

  switch (currentState) {
    case INITIAL:
      currentState = FSM.WAITING;
      break;

    case WAITING:
      fill(0);
      text("En attente de commande vocale ...", 20, 20);
      break;

    case ACTION:
      fill(0);
      text("Cliquez pour créer la forme " + recognizedForm + " de couleur " + recognizedColor, 20, 20);
      break;

    case DEPLACER_FORMES_SELECTION:
      fill(0);
      text("Cliquez sur la forme à déplacer", 20, 20);
      break;

    case DEPLACER_FORMES_DESTINATION:
      fill(0);
      text("Cliquez sur l’endroit où déplacer la forme", 20, 20);
      break;
      
    case SUPPRIMER_FORMES_SELECTION:
      fill(0);
      text("Cliquez sur la forme à supprimer ...", 20, 20);
      break;

    default:
      break;
  }
}

void mousePressed() {
  Point p = new Point(mouseX, mouseY);

  switch (currentState) {
    case ACTION:
      if (recognizedAction.equals("CREATE")) {
        if (!recognizedForm.isEmpty()) {
          createForm(p, recognizedForm, recognizedColor);
          println("Forme créée : " + recognizedForm + " à " + p);
        } else {
          println("Aucune forme reconnue, on ne fait rien.");
        }
      }
      currentState = FSM.WAITING;
      break;

    case DEPLACER_FORMES_SELECTION:
      formeSelectionnee = findClickedFormeIndex(p);
      if (formeSelectionnee != -1) {
        println("Forme à déplacer sélectionnée : index " + formeSelectionnee);
        currentState = FSM.DEPLACER_FORMES_DESTINATION;
      }
      break;

    case DEPLACER_FORMES_DESTINATION:
      if (formeSelectionnee != -1) {
        formes.get(formeSelectionnee).setLocation(p);
        println("Forme déplacée à " + p);
      }
      currentState = FSM.WAITING;
      break;
      
    case SUPPRIMER_FORMES_SELECTION:
      int index = findClickedFormeIndex(p);
      if (index != -1) {
        formes.remove(index);
        println("Forme supprimée, index = " + index);
      }
      currentState = FSM.WAITING;
      break;

    default:
      break;
  }
}

void createForm(Point p, String form, String colorName) {
  Forme newForm = null;
  switch(form) {
    case "CIRCLE":
      newForm = new Cercle(p);
      break;
    case "RECTANGLE":
      newForm = new Rectangle(p);
      break;
    case "DIAMOND":
      newForm = new Losange(p);
      break;
    case "TRIANGLE":
      newForm = new Triangle(p);
      break;
    default:
      return;
  }

  int c = translateColor(colorName);
  newForm.setColor(c);
  formes.add(newForm);
}

int translateColor(String col) {
  String colorName = col.trim().toUpperCase();
  switch (colorName) {
    case "BLUE":
      return color(0, 0, 255);
    case "RED":
      return color(255, 0, 0);
    case "GREEN":
      return color(0, 255, 0);
    case "YELLOW":
      return color(255, 255, 0);
    case "ORANGE":
      return color(255, 128, 0);
    case "PURPLE":
      return color(238,130,238);
    case "DARK":
      return color(0, 0, 0);
    default:
      println("Couleur inconnue : " + colorName + ", on prend par défaut color(127)");
      return color(127);
  }
}

int findClickedFormeIndex(Point p) {
  for (int i = 0; i < formes.size(); i++) {
    Forme f = formes.get(i);
    if (f.isClicked(p)) {
      return i;
    }
  }
  return -1;
}
