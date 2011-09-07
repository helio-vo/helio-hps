package eu.heliovo.hps.utilities;

import java.util.Random;

public class RandomUtilities 
{
	Random	rnd	=	new Random();
	
	public	int	getRandomBetween(int min, int max)
	{
		return min + rnd.nextInt(max-min);
	}
}
